//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import NefCommon
import Bow
import BowEffects


class NefCompilerSystem: CompilerSystem {
    
    func compile(xcworkspace: URL, atNefPlayground nefPlayground: NefPlaygroundURL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL> {
        binding(
            |<-self.createStructure(xcworkspace: xcworkspace, nefPlayground: nefPlayground, cached: cached),
            |<-self.buildDependencies(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildProject(xcworkspace: xcworkspace, nefPlayground: nefPlayground, platform: platform, cached: cached),
            |<-self.copyFrameworks(nefPlayground: nefPlayground),
        yield: nefPlayground.appending(.fw))^
    }
    
    func compile(page: String, filename: String, inPlayground playground: URL, atNefPlayground nefPlayground: NefPlaygroundURL, platform: Platform, frameworks: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        let content = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        let linkers = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]>.var()
        let sources = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [URL]>.var()
        
        return binding(
            content <- self.reorganizeHeaders(page: page),
            linkers <- self.dependencies(platform: platform),
            sources <- self.sources(inPlayground: playground),
                    |<-self.compile(content: content.get, filename: filename,
                                    inPlayground: playground, atNefPlayground: nefPlayground,
                                    sources: sources.get,
                                    platform: platform,
                                    frameworks: frameworks, linkers: linkers.get),
        yield: ())^
    }
    
    // MARK: - steps <shell>
    private func createStructure(xcworkspace: URL, nefPlayground: NefPlaygroundURL, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        EnvIO { env in
            let cleanBuildIO = env.fileSystem.remove(itemPath: nefPlayground.appending(.build).path).handleError { _ in }
            let cleanLogIO = env.fileSystem.remove(itemPath: nefPlayground.appending(.log).path).handleError { _ in }
            let cleanRootIO = env.fileSystem.remove(itemPath: nefPlayground.appending(.nef).path).handleError { _ in }
            let cleanIO = cached ? cleanBuildIO.followedBy(cleanLogIO) : cleanRootIO
            let cleanDependenciesIO = env.playgroundShell.clean(playground: nefPlayground).provide(env.fileSystem).mapError { _ in FileSystemError.remove(item: "") }
            
            let createDerivedDataIO = env.fileSystem.createDirectory(atPath: nefPlayground.appending(.derivedData).path)
            let createFrameworksIO = env.fileSystem.createDirectory(atPath: nefPlayground.appending(.fw).path)
            let createLogIO = env.fileSystem.createDirectory(atPath: nefPlayground.appending(.log).path)
            
            return cleanIO.followedBy(cleanDependenciesIO)
                    .followedBy(createDerivedDataIO)
                    .followedBy(createFrameworksIO)
                    .followedBy(createLogIO)^
                    .mapError { _ in .build(nefPlayground.project, info: "creating the project structure") }
        }
    }
    
    private func buildDependencies(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        binding(
            |<-self.buildPods(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildCarthage(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildSPM(xcworkspace: xcworkspace, platform: platform, cached: cached),
        yield: ())^
    }
    
    private func copyFrameworks(nefPlayground: NefPlaygroundURL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        func items(nefPlayground: NefPlaygroundURL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            EnvIO { env in
                return env.fileSystem.items(atPath: nefPlayground.appending(.derivedData).appendingPathComponent("Build").path, recursive: true)
                                     .mapError { _ in .build(nefPlayground.project, info: "get frameworks") }
            }
        }
        
        func extractFrameworks(paths: [String]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            let frameworks = paths.filter { $0.filename.extension == "framework" }
            guard frameworks.count > 0 else { return EnvIO.raiseError(.build(info: "copy frameworks: no frameworks found!"))^ }
            return EnvIO.pure(frameworks)^
        }
        
        func copyFrameworks(paths: [String], nefPlayground: NefPlaygroundURL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                env.fileSystem.copy(itemPaths: paths, to: nefPlayground.appending(.fw).path).void()
            }.mapError { _ in .build(nefPlayground.project, info: "move frameworks into '\(nefPlayground.project.path)'") }
        }
        
        let paths = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        let frameworks = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        
        return binding(
                   paths <- items(nefPlayground: nefPlayground),
              frameworks <- extractFrameworks(paths: paths.get),
                         |<-copyFrameworks(paths: frameworks.get, nefPlayground: nefPlayground),
        yield: ())^
    }
    
    private func buildProject(xcworkspace: URL, nefPlayground: NefPlaygroundURL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL> {
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
        
        func build(xcworkspace: URL, nefPlayground: NefPlaygroundURL, scheme: String, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                let xcworkspaceName = xcworkspace.lastPathComponent.removeExtension
                let derivedData = nefPlayground.appending(.derivedData)
                let workspaceFramework = nefPlayground.appending(filename: xcworkspaceName, in: .fw)
                let log = nefPlayground.appending(filename: xcworkspaceName, in: .log)
                
                let isCached = cached && env.fileSystem.exist(itemPath: workspaceFramework.path)
                guard !isCached else { return IO.pure(()) }
                
                return env.shell.build(xcworkspace: xcworkspace, scheme: scheme, platform: platform, derivedData: derivedData, log: log)
            }.mapError { (e: CompilerShellError) in CompilerSystemError.build(xcworkspace, info: "\(e)") }
        }
        
        let schemeName = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        
        return binding(
            schemeName <- extractScheme(xcworkspace: xcworkspace),
                       |<-build(xcworkspace: xcworkspace, nefPlayground: nefPlayground, scheme: schemeName.get, platform: platform, cached: cached),
        yield: nefPlayground.appending(.fw))^
    }
    
    private func compile(content: String, filename: String, inPlayground playground: URL, atNefPlayground nefPlayground: NefPlaygroundURL, sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        EnvIO { env in
            let playgroundName = playground.lastPathComponent.removeExtension
            let filename = "\(playgroundName)-\(filename).swift".lowercased()
            let output = nefPlayground.appending(filename: filename, in: .build)
            let log = nefPlayground.appending(filename: filename, in: .log)
            let temporal = IO<CompilerSystemError, URL>.var()
            
            return binding(
                temporal <- env.fileSystem.temporalFile(content: content, filename: "main.swift").mapError { e in .build(info: "\(e)") },
                         |<-env.shell.compile(file: temporal.get,
                                              sources: sources,
                                              platform: platform,
                                              frameworks: frameworks,
                                              linkers: linkers,
                                              output: output, log: log).mapError { e in .build(temporal.get, info: "\(e)") },
                         |<-env.fileSystem.write(content: content, toFile: output.path).mapError { e in .build(output, info: "\(e)") },
            yield: ())
        }
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
                page.matches(pattern: "(?<=\nimport).*(?=\n)"))).map { fw in
                    fw.trimmingCharacters(in: .whitespaces)
                }.sorted(by: >)
            )^
        }
        
        func removeImports(_ imports: [String], inPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.reduce(page) { (acc, fw) in
                    acc.replacingOccurrences(of: "\nimport \(fw)", with: "")
                }
            )^
        }
        
        func insertHeaders(_ imports: [String], toPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.reduce(page) { (acc, fw) in
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
        EnvIO { env in
            let sources = playground.appendingPathComponent("Sources")
            return env.fileSystem.items(atPath: sources.path, recursive: true)
                                 .map { items in items.map(URL.init(fileURLWithPath:)) }^
                                 .mapError { _ in .build() }.handleError { _ in [] }^
        }
    }
    
    // MARK: helpers <path>
    
}
