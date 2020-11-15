//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefPlayground
import Bow
import BowEffects
import Swiftline

final class MacNefPlaygroundSystem: NefPlaygroundSystem {
    
    func installTemplate(into output: URL, name: String, platform: Platform) -> EnvIO<FileSystem, NefPlaygroundSystemError, NefPlaygroundURL> {
        func existPlayground(at output: URL, name: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
            EnvIO { fileSystem in
                let app = output.appendingPathComponent("\(name).app")
                
                if fileSystem.exist(itemPath: app.path) {
                    return IO.raiseError(.template(info: "nef playground '\(name)' already exists"))^
                } else {
                    return IO.pure(())^
                }
            }
        }
        
        let template = EnvIO<FileSystem, NefPlaygroundSystemError, URL>.var()
        let playground = EnvIO<FileSystem, NefPlaygroundSystemError, NefPlaygroundURL>.var()
        
        return binding(
                        |<-existPlayground(at: output, name: name),
               template <- self.downloadTemplate(into: output),
                        |<-self.installTemplate(template.get, name: name),
             playground <- self.nefPlayground(name: name, fromTemplate: template.get),
                        |<-self.setPlaygroundPlatform(playground: playground.get, platform: platform),
                        |<-self.configureLauncher(playground: playground.get, name: name),
        yield: playground.get)^
    }
    
    func setDependencies(_ dependencies: PlaygroundDependencies, playground: NefPlaygroundURL, xcodeprojs: NEA<URL>, target: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        switch dependencies {
        case .bow(let bow):
            return setDependencies(playground: playground, bow: bow)
        case .spm:
            return setSPM(playground: playground)
        case .cocoapods(let podfile):
            return setCocoapods(playground: playground, target: target, podfile: podfile)
        case .carthage(let cartfile):
            let xcodeproj = xcodeprojs.find { url in url.path.contains(playground.appending(.carthageTemplate).path) }.getOrElse { xcodeprojs.head }
            return setCarthage(playground: playground, xcodeproj: xcodeproj, cartfile: cartfile)
        }
    }
    
    func linkPlaygrounds(_ playgrounds: NEA<URL>,  xcworkspace: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        func extractPlaygroundsNames(in xcworkspace: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, [String]> {
            EnvIO { fileSystem in
                let workspaceContentFile = xcworkspace.appendingPathComponent("contents.xcworkspacedata")
                
                return fileSystem.readFile(atPath: workspaceContentFile.path)
                                 .map { content in content.matches(pattern: "(?<=location = \"group:).*(?=.playground\")") }^
                                 .mapError { e in .linking(info: "\(e)") }
            }
        }
        
        func difference(playgrounds: NEA<URL>, names: [String]) -> EnvIO<FileSystem, NefPlaygroundSystemError, [URL]> {
            let playgroundsNames = names.map { $0.removeExtension.lowercased() }
            let filtered = playgrounds.all().filter { playground in
                let playgroundName = playground.lastPathComponent.removeExtension.lowercased()
                return !playgroundsNames.contains(playgroundName)
            }
            
            return EnvIO.pure(filtered)^
        }
        
        func link(playgrounds: [URL], into xcworkspace: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
            EnvIO { fileSystem in
                let xcworkspacedataFile = xcworkspace.appendingPathComponent("contents.xcworkspacedata")
                let playgroundRefs = playgrounds.map { playground in
                    "<FileRef location = \"group:\(playground.lastPathComponent.removeExtension).playground\"></FileRef>"
                }
                
                return fileSystem.readFile(atPath: xcworkspacedataFile.path)
                                 .map { content in content.replacingFirstOccurrence(of: "<FileRef", with: "\(playgroundRefs.joined(separator: "\n\t"))\n\t<FileRef") }
                                 .flatMap { content in fileSystem.write(content: content, toFile: xcworkspacedataFile.path) }^
                                 .mapError { _ in .linking() }.void()^
            }
        }
        
        let playgroundsNames = EnvIO<FileSystem, NefPlaygroundSystemError, [String]>.var()
        let linkPlaygrounds = EnvIO<FileSystem, NefPlaygroundSystemError, [URL]>.var()
        
        return binding(
            playgroundsNames <- extractPlaygroundsNames(in: xcworkspace),
             linkPlaygrounds <- difference(playgrounds: playgrounds, names: playgroundsNames.get),
                             |<-link(playgrounds: linkPlaygrounds.get, into: xcworkspace),
        yield: ())^
    }
    
    func clean(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        binding(
            |<-self.cleanTemplates(playground: playground),
            |<-self.cleanDependencies(playground: playground),
            |<-self.cleanBinaries(playground: playground),
        yield: ())^
    }
    
    // MARK: - steps
    private func downloadTemplate(into output: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, URL> {
        func downloadZip(into output: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, URL> {
            EnvIO.invoke { _ in
                let zip = output.appendingPathComponent("\(BuildConfiguration.templateVersion).zip")
                let result = run("curl", args: ["-LkSs", Template.path, "-o", zip.path])
                guard result.exitStatus == 0 else {
                    throw NefPlaygroundSystemError.template(info: result.stderr)
                }
                
                return zip
            }
        }
        
        func unzip(_ zip: URL, into output: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, URL> {
            func unzip(_ zip: URL, output: URL, log: URL) -> IO<FileSystemError, Void> {
                IO.invoke {
                    let result = run("/usr/bin/unzip", args: [zip.path, "-d", output.path.trimmingEmptyCharacters]) { settings in settings.execution = .log(file: log.path) }
                    guard result.exitStatus == 0 else { throw FileSystemError.create(item: "unzip \(output.path): \(result.stderr)") }
                    return ()
                }
            }
            
            return EnvIO { fileSystem in
                let templateName = "nef-\(BuildConfiguration.templateVersion)"
                let unzipFolder = output.appendingPathComponent(templateName)
                
                let cleamTemplateIO = fileSystem.removeDirectory(unzipFolder.path).handleError { _ in }
                let createTemplateIO = fileSystem.createDirectory(atPath: unzipFolder.path)
                let unzipIO = unzip(zip, output: output, log: unzipFolder.appendingPathComponent("unzip.log"))
                
                return cleamTemplateIO
                        .followedBy(createTemplateIO)
                        .followedBy(unzipIO)
                        .map { unzipFolder }^
                        .mapError { e in .template(info: "\(e)") }
            }
        }
        
        func removeItem(at item: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
            EnvIO { fileSystem in
                fileSystem.removeDirectory(item.path).mapError { e in .template(info: "\(e)") }
            }
        }
        
        let zip = EnvIO<FileSystem, NefPlaygroundSystemError, URL>.var()
        let template = EnvIO<FileSystem, NefPlaygroundSystemError, URL>.var()
        
        return binding(
                  zip <- downloadZip(into: output),
             template <- unzip(zip.get, into: output),
                      |<-removeItem(at: zip.get),
        yield: template.get)^
    }
    
    private func installTemplate(_ template: URL, name: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO.invoke { _ in
            let script = template.appendingPathComponent("setup").appendingPathComponent("nef.rb")
            let result = run("ruby", args: [script.path, template.path, name])
            guard result.exitStatus == 0 else {
                throw NefPlaygroundSystemError.template(info: result.stderr)
            }
            
            return ()
        }
    }
    
    private func nefPlayground(name: String, fromTemplate template: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, NefPlaygroundURL> {
        EnvIO { fileSystem in
            let templateApp = template.appendingPathComponent("\(name).app")
            let playground = NefPlaygroundURL(folder: template.deletingLastPathComponent(), name: name)
            
            let moveAppIO = fileSystem.moveFile(from: templateApp.path, to: playground.project.path)
            let moveTemplateFilesIO = fileSystem.moveFiles(in: template.path, to: playground.appending(.contentFiles).path)
            
            return moveAppIO.followedBy(moveTemplateFilesIO)^
                    .mapError { e in .template(info: "\(e)") }
                    .map { playground }^
        }
    }
    
    private func configureLauncher(playground: NefPlaygroundURL, name: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            fileSystem.readFile(atPath: playground.appending(.launcher).path)
                      .map { content in content.replacingOccurrences(of: "{{nef}}", with: name) }
                      .flatMap { content in fileSystem.write(content: content, toFile: playground.appending(.launcher).path) }^
                      .mapError { e in .template(info: "\(e)") }
        }
    }
    
    private func setPlaygroundPlatform(playground: NefPlaygroundURL, platform: Platform) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            guard platform == .ios || platform == .macos else {
                return IO.raiseError(.template(info: "received invalid platform \(platform), you must set platform to 'ios' or 'osx'"))^
            }
            
            let platformFiles = playground.appending(.contentFiles).appendingPathComponent(platform == .ios ? "ios" : "osx")
            let otherPlatformFolder = playground.appending(.contentFiles).appendingPathComponent(platform == .ios ? "osx" : "ios")
            
            let removeOtherPlatformIO = fileSystem.removeDirectory(otherPlatformFolder.path)
            let moveFilesIO = fileSystem.moveFiles(in: platformFiles.path, to: playground.appending(.contentFiles).path)
            
            return removeOtherPlatformIO.followedBy(moveFilesIO)^.mapError { e in .template(info: "\(e)") }
        }
    }
    
    // MARK: dependencies
    private func setDependencies(playground: NefPlaygroundURL, bow: PlaygroundDependencies.Bow) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        func dependency(bow: PlaygroundDependencies.Bow, lastBowVersion: String) -> String {
            switch bow {
            case .version(let version): return "\"~> \(version.isEmpty ? lastBowVersion : version)\""
            case .branch(let branch):   return ":git => '\(Bow.repository)', :branch => '\(branch)'"
            case .tag(let tag):         return ":git => '\(Bow.repository)', :tag => '\(tag)'"
            case .commit(let commit):   return ":git => '\(Bow.repository)', :commit => '\(commit)'"
            }
        }
        
        func updateBowDependency(podfile: URL, with: PlaygroundDependencies.Bow, lastBowVersion: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
            EnvIO { fileSystem in
                let readPodfileIO = fileSystem.readFile(atPath: podfile.path)
                let writeContentIO = { (content: String) in fileSystem.write(content: content, toFile: podfile.path) }
                let setDependencyIO = { (content: String) in content.replacingOccurrences(of: "\"~> 0.0.0\"", with: dependency(bow: bow, lastBowVersion: lastBowVersion)) }
                
                return readPodfileIO
                        .map(setDependencyIO)
                        .flatMap(writeContentIO)^
                        .mapError { _ in .dependencies() }
            }
        }
        
        let podfile = playground.appending(pathComponent: "Podfile", in: .contentFiles)
        let lastBowVersion = EnvIO<FileSystem, NefPlaygroundSystemError, String>.var()
        
        return binding(
                           |<-self.checkCocoaPod(),
            lastBowVersion <- self.lastBowVersion(),
                           |<-self.moveFiles(at: playground.appending(.cocoapodsTemplate), into: playground.appending(.contentFiles)),
                           |<-self.cleanTemplates(playground: playground),
                           |<-updateBowDependency(podfile: podfile, with: bow, lastBowVersion: lastBowVersion.get),
                           |<-self.createCocoaPodsWorkspace(playground: playground),
        yield: ())^
    }
    
    private func setCocoapods(playground: NefPlaygroundURL, target: String, podfile: URL?) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        func updateTarget(podfile: URL, with target: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
            EnvIO { fileSystem in
                let readPodfileIO = fileSystem.readFile(atPath: podfile.path)
                let writeContentIO = { (content: String) in fileSystem.write(content: content, toFile: podfile.path) }
                let replaceTarget = { (content: String) -> String in
                    guard let replaceTarget = content.matches(pattern: "(?<=target ').*(?=' do)").first else { return content }
                    return content.replacingOccurrences(of: "target '\(replaceTarget)' do", with: "target '\(target)' do")
                }
                
                return readPodfileIO
                        .map(replaceTarget)
                        .flatMap(writeContentIO)^
                        .mapError { _ in .dependencies() }
            }
        }
        
        let contentPodfile = playground.appending(pathComponent: "Podfile", in: .contentFiles)
        let defaultPodfile = """
                             platform :ios, '12.0'
                             use_frameworks!

                             target 'Default' do
                             end
                             """
        
        return binding(
            |<-self.checkCocoaPod(),
            |<-self.moveFiles(at: playground.appending(.cocoapodsTemplate), into: playground.appending(.contentFiles)),
            |<-self.cleanTemplates(playground: playground),
            |<-self.rewriteFile(contentPodfile, content: defaultPodfile),
            |<-self.rewriteFile(contentPodfile, withFile: podfile),
            |<-updateTarget(podfile: contentPodfile, with: target),
            |<-self.createCocoaPodsWorkspace(playground: playground),
        yield: ())^
    }
    
    private func setCarthage(playground: NefPlaygroundURL, xcodeproj: URL, cartfile: URL?) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        let contentCartfile = playground.appending(pathComponent: "Cartfile", in: .contentFiles)
        let defaultCartfile = ""
        
        return binding(
            |<-self.checkCarthage(),
            |<-self.emptyWorkspace(xcodeproj: xcodeproj),
            |<-self.moveFiles(at: playground.appending(.carthageTemplate), into: playground.appending(.contentFiles)),
            |<-self.cleanTemplates(playground: playground),
            |<-self.rewriteFile(contentCartfile, content: defaultCartfile),
            |<-self.rewriteFile(contentCartfile, withFile: cartfile),
        yield: ())^
    }
    
    private func setSPM(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        return binding(
            |<-self.moveFiles(at: playground.appending(.spmTemplate), into: playground.appending(.contentFiles)),
            |<-self.cleanTemplates(playground: playground),
        yield: ())^
    }
    
    private func cleanTemplates(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            let dependencies = [playground.appending(.cocoapodsTemplate),
                                playground.appending(.carthageTemplate),
                                playground.appending(.spmTemplate)]
            
            return dependencies.traverse { template in fileSystem.removeDirectory(template.path).handleError { _ in } }^
                               .mapError { e in .dependencies(info: "clean templates: \(e)") }
                               .void()
        }
    }
    
    private func cleanDependencies(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        binding(
            |<-self.cleanPods(playground: playground).handleError { _ in },
            |<-self.cleanCarthage(playground: playground).handleError { _ in },
        yield: ())^
    }
    
    private func cleanBinaries(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            fileSystem.remove(itemPath: playground.appending(.nef).path)^
                      .mapError { _ in .clean() }.handleError { _ in }
        }
    }
    
    private func emptyWorkspace(xcodeproj: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            let xcworkspace = xcodeproj.deletingPathExtension().appendingPathExtension("xcworkspace")
            guard !fileSystem.exist(itemPath: xcworkspace.path) else { return IO.pure(())^ }
            
            let xcworkspacedata = """
                                  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
                                  <Workspace
                                      version = \"1.0\">
                                        <FileRef location = \"container:\(xcodeproj.lastPathComponent)\"></FileRef>
                                  </Workspace>
                                  """
            
            let createWorkspaceIO = fileSystem.createDirectory(atPath: xcworkspace.path)
            let writeWorkspaceDataIO = fileSystem.write(content: xcworkspacedata, toFile: xcworkspace.appendingPathComponent("contents.xcworkspacedata").path)
            
            return createWorkspaceIO
                    .followedBy(writeWorkspaceDataIO)^
                    .mapError { e in .dependencies(info: "\(e)") }
        }
    }
    
    // MARK: helpers <dependencies>
    private func lastBowVersion() -> EnvIO<FileSystem, NefPlaygroundSystemError, String> {
        EnvIO.invoke { _ in
            let result = run("curl", args: ["--silent", Bow.tags])
            guard result.exitStatus == 0,
                  let lastVersion = result.stdout.matches(pattern: "(?<=name\": \").*(?=\")").first else {
                throw NefPlaygroundSystemError.dependencies(info: result.stderr)
            }
            
            return lastVersion
        }
    }
    
    private func checkCocoaPod() -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO.invoke { _ in
            let result = run("pod", args: ["--version"])
            guard result.exitStatus == 0 else {
                throw NefPlaygroundSystemError.dependencies(info: "Required CocoaPods. Run 'sudo gem install cocoapods'\n\(result.stderr)")
            }
            
            return ()
        }
    }
    
    private func checkCarthage() -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO.invoke { _ in
            let result = run("carthage")
            guard result.exitStatus == 0 else {
                throw NefPlaygroundSystemError.dependencies(info: "Required Carthage. Run 'brew install carthage'\n\(result.stderr)")
            }
            
            return ()
        }
    }
    
    private func createCocoaPodsWorkspace(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO.invoke { _ in
            let result = run("pod", args: ["install", "--project-directory=\(playground.appending(.contentFiles).path)"])
            guard result.exitStatus == 0 else {
                throw NefPlaygroundSystemError.dependencies(info: "creating xcworkspace using CocoaPods: \(result.stderr) \(result.stdout)")
            }
            
            return ()
        }
    }
    
    private func cleanPods(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            let pods = playground.appending(pathComponent: "Pods", in: .contentFiles)
            let resolved = playground.appending(pathComponent: "Podfile", extension: "lock", in: .contentFiles)
            
            let podsIO = fileSystem.remove(itemPath: pods.path).handleError { _ in }
            let resolvedIO = fileSystem.remove(itemPath: resolved.path).handleError { _ in }
            
            return podsIO.followedBy(resolvedIO)^.mapError { _ in .clean() }
        }
    }
    
    private func cleanCarthage(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            let cartfile = playground.appending(pathComponent: "Carthage", in: .contentFiles)
            let resolved = playground.appending(pathComponent: "Cartfile", extension: "resolved", in: .contentFiles)
            
            let cartfileIO = fileSystem.remove(itemPath: cartfile.path).handleError { _ in }
            let resolvedIO = fileSystem.remove(itemPath: resolved.path).handleError { _ in }
            
            return cartfileIO.followedBy(resolvedIO)^.mapError { _ in .clean() }
        }
    }
    
    // MARK: helpers <file manager>
    private func moveFiles(at input: URL, into output: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { fileSystem in
            fileSystem.moveFiles(in: input.path, to: output.path).mapError { _ in .dependencies() }
        }
    }
    
    private func rewriteFile(_ file: URL, withFile newFile: URL?) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        guard let newFile = newFile else { return .pure(())^ }
        
        return EnvIO { fileSystem in
            let removeOldFileIO = fileSystem.remove(itemPath: file.path).handleError { _ in }
            let copyNewFileIO = fileSystem.copy(itemPath: newFile.path, toPath: file.path)
            
            return removeOldFileIO.followedBy(copyNewFileIO)^.mapError { _ in .dependencies() }
        }
    }
    
    private func rewriteFile(_ file: URL, content: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void> {
        EnvIO { (fileSystem: FileSystem) in
            let removeOldFileIO = fileSystem.remove(itemPath: file.path).handleError { _ in }
            let copyContentIO = fileSystem.write(content: content, toFile: file.path)
            
            return removeOldFileIO.followedBy(copyContentIO)^.mapError { _ in .dependencies() }
        }
    }
    
    // MARK: - Constants
    private enum Template {
        static let path = "https://github.com/bow-swift/nef/archive/\(BuildConfiguration.templateVersion).zip"
    }
    
    private enum Bow {
        static let tags = "https://api.github.com/repos/bow-swift/bow/tags"
        static let repository = "https://github.com/bow-swift/bow.git"
    }
}
