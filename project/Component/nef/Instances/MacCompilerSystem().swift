//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCompiler
import Bow
import BowEffects


class MacCompilerSystem: CompilerSystem {
    
    func compile(xcworkspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL> {
        return EnvIO.pure(self.frameworks(project: project))^
        
        #warning("enable this code")
        binding(
            |<-self.createStructure(project: project, cached: cached),
            |<-self.buildDependencies(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildProject(xcworkspace: xcworkspace, inProject: project, platform: platform, cached: cached),
            |<-self.copyFrameworks(inProject: project),
        yield: self.frameworks(project: project))^
    }
    
    func compile(page: String, inPlayground playground: URL, platform: Platform, frameworks: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        let content = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        let linkers = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]>.var()
        let sources = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]>.var()
        
        return binding(
            content <- self.reorganizeHeaders(page: page),
            linkers <- self.dependencies(platform: platform),
            sources <- self.sources(inPlayground: playground),
                    |<-self.compile(content: content.get, sources: sources.get, platform: platform, frameworks: frameworks, linkers: linkers.get),
        yield: ())^
    }
    
    // MARK: - steps <shell>
    private func createStructure(project: URL, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        EnvIO { env in
            let cleanIO = cached ? env.fileSystem.remove(itemPath: self.frameworks(project: project).path).handleError { _ in }
                                 : env.fileSystem.remove(itemPath: self.nef(project: project).path).handleError { _ in }
            
            let createDerivedDataIO = env.fileSystem.createDirectory(atPath: self.derivedData(project: project).path)
            let createFrameworksIO = env.fileSystem.createDirectory(atPath: self.frameworks(project: project).path)
            let createLogIO = env.fileSystem.createDirectory(atPath: self.log(project: project).path)
            
            return cleanIO
                    .followedBy(createDerivedDataIO)
                    .followedBy(createFrameworksIO)
                    .followedBy(createLogIO)^
                    .mapError { _ in .build(project, info: "creating the project structure") }
        }
    }
    
    private func buildDependencies(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        binding(
            |<-self.buildPods(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildCarthage(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildSPM(xcworkspace: xcworkspace, platform: platform, cached: cached),
        yield: ())^
    }
    
    private func copyFrameworks(inProject project: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        func items(inProject project: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            EnvIO { env in
                let buildFolder = self.derivedData(project: project).appendingPathComponent("Build")
                return env.fileSystem.items(atPath: buildFolder.path, recursive: true)
                                     .mapError { _ in .build(project, info: "get frameworks in '\(project.path)'") }
            }
        }
        
        func extractFrameworks(paths: [String]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            let frameworks = paths.filter { $0.filename.extension == "framework" }
            guard frameworks.count > 0 else { return EnvIO.raiseError(.build(project, info: "copy frameworks: no frameworks found!"))^ }
            return EnvIO.pure(frameworks)^
        }
        
        func copyFrameworks(paths: [String], to output: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                env.fileSystem.copy(itemPaths: paths, to: output.path).void()
            }.mapError { _ in .build(project, info: "move frameworks into '\(output.path)'") }
        }
        
        let fwFolder = self.frameworks(project: project)
        let paths = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        let frameworks = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        
        return binding(
                   paths <- items(inProject: project),
              frameworks <- extractFrameworks(paths: paths.get),
                         |<-copyFrameworks(paths: frameworks.get, to: fwFolder),
        yield: ())^
    }
    
    private func buildProject(xcworkspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL> {
        func scheme(pbxproj: String, name: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            let schemes = pbxproj.matches(pattern: "(?s)(/\\* Begin PBX\(name.capitalized)Target section.*\n).*(End PBX\(name.capitalized)Target section \\*/)").joined()
                                 .matches(pattern: "(?<=\tname = ).*(?=;)")
            
            guard let scheme = schemes.first else { return EnvIO.raiseError(.build(xcworkspace))^ }
            return EnvIO.pure(scheme)^
        }
        
        func scheme(pbxproj: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            let nativeTargetIO    = scheme(pbxproj: pbxproj, name: "native")
            let aggregateTargetIO = scheme(pbxproj: pbxproj, name: "aggregate")
            
            return nativeTargetIO.handleErrorWith(constant(aggregateTargetIO))^
        }
        
        func extractScheme(xcworkspace: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            let pbxproj = xcworkspace.deletingPathExtension().appendingPathExtension("xcodeproj").appendingPathComponent("project.pbxproj")
            let env = EnvIO<CompilerSystemEnvironment, CompilerSystemError, CompilerSystemEnvironment>.var()
            let content = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
            let schemeName = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
            
            return binding(
                       env <- ask(),
                   content <- env.get.fileSystem.readFile(atPath: pbxproj.path).mapError { _ in .build(xcworkspace) }^,
                schemeName <- scheme(pbxproj: content.get),
            yield: schemeName.get)^
        }
        
        func build(xcworkspace: URL, inProject project: URL, scheme: String, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                let workspaceFramework = self.framework(xcworkspace: xcworkspace, inProject: project)
                let isCached = cached && env.fileSystem.exist(itemPath: workspaceFramework.path)
                guard !isCached else { return IO.pure(()) }
                
                let derivedData = self.derivedData(project: project)
                let log = self.log(xcworkspace: xcworkspace, inProject: project)
                
                return env.shell.build(xcworkspace: xcworkspace, scheme: scheme, platform: platform, derivedData: derivedData, log: log)
            }.mapError { (e: CompilerShellError) in CompilerSystemError.build(xcworkspace, info: "\(e)") }
        }
        
        let schemeName = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        
        return binding(
            schemeName <- extractScheme(xcworkspace: xcworkspace),
                       |<-build(xcworkspace: xcworkspace, inProject: project, scheme: schemeName.get, platform: platform, cached: cached),
        yield: self.frameworks(project: project))^
    }
    
    private func compile(content: String, sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        fatalError()
        
        //        # A. macOS paltform
        //        if [ "$platformIOS" -eq "0" ]; then
        //            if [ "${#hasSourceFolderFiles}" -gt 0 ]; then
        //              xcrun -k swiftc -D NOT_IN_PLAYGROUND -F "nef/build/fw" -F "$macOSFwPath" -Xlinker -rpath -Xlinker "$macOSFwPath" -lswiftCore "$file" "$sources"/* -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            else
        //              xcrun -k swiftc -D NOT_IN_PLAYGROUND -F "nef/build/fw" -F "$macOSFwPath" -Xlinker -rpath -Xlinker "$macOSFwPath" -lswiftCore "$file" -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            fi
        //
        //        # B. iOS platform
        //        else
        //            if [ "${#hasSourceFolderFiles}" -gt 0 ]; then
        //              xcrun -k -sdk "iphoneos" swiftc -D NOT_IN_PLAYGROUND -target "arm64-apple-ios13.0" -F "nef/build/fw" -F "$iOSFwPath" -Xlinker -rpath -Xlinker "$iOSFwPath" -lswiftXCTest "$file" "$sources"/* -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            else
        //              xcrun -k -sdk "iphoneos" swiftc -D NOT_IN_PLAYGROUND -target "arm64-apple-ios13.0" -F "nef/build/fw" -F "$iOSFwPath" -Xlinker -rpath -Xlinker "$iOSFwPath" -lswiftXCTest "$file" -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            fi
        //        fi
    }
    
    // MARK: - dependencies <shell>
    private func buildPods(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        func resolve(project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                let hasPodfile = env.fileSystem.exist(itemPath: project.appendingPathComponent("Podfile").path)
                return hasPodfile ? env.shell.podinstall(project: project, platform: platform, cached: cached).mapError { e in .dependencies(project, info: "\(e)") }
                                  : IO.pure(())^
            }^
        }
        
        return resolve(project: xcworkspace.deletingLastPathComponent(),
                       platform: platform,
                       cached: cached)
    }
    
    private func buildCarthage(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        func resolve(project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                let hasCartfile = env.fileSystem.exist(itemPath: project.appendingPathComponent("Cartfile").path)
                return hasCartfile ? env.shell.carthage(project: project, platform: platform, cached: cached).mapError { e in .dependencies(project, info: "\(e)") }
                                   : IO.pure(())^
            }^
        }
        
        return resolve(project: xcworkspace.deletingLastPathComponent(),
                       platform: platform,
                       cached: cached)
    }
    
    private func buildSPM(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        #warning("it must be done when apple fixes the Xcode bug '47668990'")
        return EnvIO.pure(())^
    }
    
    // MARK: - helpers
    private func reorganizeHeaders(page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
        func getImports(page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            EnvIO.pure(Array(Set(
                page.matches(pattern: "(?<=import).*(?=\n)"))).map { fw in
                    fw.trimmingCharacters(in: .whitespaces)
                }
            )^
        }
        
        func removeImports(_ imports: [String], inPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.reduce(page) { (acc, fw) in
                    acc.replacingOccurrences(of: "import \(fw)", with: "")
                }
            )^
        }
        
        func insertHeaders(_ imports: [String], toPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.sorted(by: >).reduce(page) { (acc, fw) in
                    "import \(fw)\n\(acc)"
                }
            )^
        }
        
        let imports = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        let cleaned = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        let output  = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        
        return binding(
            imports <- getImports(page: page),
            cleaned <- removeImports(imports.get, inPage: page),
             output <- insertHeaders(imports.get, toPage: cleaned.get),
        yield: output.get)^
    }
    
    private func dependencies(platform: Platform) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]> {
        EnvIO { env in
            env.shell.dependencies(platform: platform)
                .mapError { _ in .dependencies() }
                .map { [$0] }^
        }
    }
    
    private func sources(inPlayground playground: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]> {
        EnvIO { (env: CompilerSystemEnvironment) in
            let sources = playground.appendingPathComponent("Sources")
            return env.fileSystem.exist(itemPath: sources.path) ? IO.pure([sources])^ : IO.pure([])^
        }
    }
    
    // MARK: helpers <path>
    func nef(project: URL) -> URL {
        project.appendingPathComponent("nef")
    }
    
    func derivedData(project: URL) -> URL {
        nef(project: project).appendingPathComponent("DerivedData")
    }
    
    func log(project: URL) -> URL {
        nef(project: project).appendingPathComponent("log")
    }
    
    func frameworks(project: URL) -> URL {
        nef(project: project).appendingPathComponent("build").appendingPathComponent("fw")
    }
    
    func framework(xcworkspace: URL, inProject project: URL) -> URL {
        frameworks(project: project).appendingPathComponent(xcworkspace.lastPathComponent.removeExtension).appendingPathExtension("framework")
    }
    
    func log(xcworkspace: URL, inProject project: URL) -> URL {
        log(project: project).appendingPathComponent(xcworkspace.lastPathComponent.removeExtension).appendingPathExtension("log")
    }
}