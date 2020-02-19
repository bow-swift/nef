//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefPlayground
import Bow
import BowEffects
import Swiftline

class MacPlaygroundShell: PlaygroundShell {
    
    func installTemplate(into output: URL, name: String, platform: Platform) -> EnvIO<FileSystem, PlaygroundShellError, NefPlaygroundURL> {
        func existPlayground(at output: URL, name: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
            EnvIO { fileSystem in
                let app = output.appendingPathComponent("\(name).app")
                
                if fileSystem.exist(itemPath: app.path) {
                    return IO.raiseError(PlaygroundShellError.template(info: "nef playground '\(name)' already exists"))^
                } else {
                    return IO.pure(())^
                }
            }
        }
        
        let template = EnvIO<FileSystem, PlaygroundShellError, URL>.var()
        let playground = EnvIO<FileSystem, PlaygroundShellError, NefPlaygroundURL>.var()
        
        return binding(
                        |<-existPlayground(at: output, name: name),
               template <- self.downloadTemplate(into: output),
                        |<-self.installTemplate(template.get, name: name),
             playground <- self.nefPlayground(name: name, fromTemplate: template.get),
                        |<-self.setPlaygroundPlatform(playground: playground.get, platform: platform),
                        |<-self.configureLauncher(playground: playground.get, name: name),
        yield: playground.get)^
    }
    
    func setDependencies(_ dependencies: PlaygroundDependencies, playground: NefPlaygroundURL, inXcodeproj xcodeproj: URL, target: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        switch dependencies {
        case .bow(let bow):
            return setDependencies(playground: playground, bow: bow)
        case .cartfile(let url):
            return setDependencies(playground: playground, xcodeproj: xcodeproj, cartfile: url)
        case .podfile(let url):
            return setDependencies(playground: playground, target: target, podfile: url)
        }
    }
    
    func linkPlaygrounds(_ playgrounds: NEA<URL>,  xcworkspace: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        func extractPlaygroundsNames(in xcworkspace: URL) -> EnvIO<FileSystem, PlaygroundShellError, [String]> {
            EnvIO { fileSystem in
                let workspaceContentFile = xcworkspace.appendingPathComponent("contents.xcworkspacedata")
                
                return fileSystem.readFile(atPath: workspaceContentFile.path)
                                 .map { content in content.matches(pattern: "(?<=location = \"group:).*(?=.playground\")") }^
                                 .mapError { e in PlaygroundShellError.linking(info: "\(e)") }
            }
        }
        
        func difference(playgrounds: NEA<URL>, names: [String]) -> EnvIO<FileSystem, PlaygroundShellError, [URL]> {
            let playgroundsNames = names.map { $0.removeExtension.lowercased() }
            let filtered = playgrounds.all().filter { playground in
                let playgroundName = playground.lastPathComponent.removeExtension.lowercased()
                return !playgroundsNames.contains(playgroundName)
            }
            
            return EnvIO.pure(filtered)^
        }
        
        func link(playgrounds: [URL], into xcworkspace: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
            EnvIO { fileSystem in
                let xcworkspacedataFile = xcworkspace.appendingPathComponent("contents.xcworkspacedata")
                let playgroundRefs = playgrounds.map { playground in
                    "<FileRef location = \"group:\(playground.lastPathComponent.removeExtension).playground\"></FileRef>"
                }
                
                return fileSystem.readFile(atPath: xcworkspacedataFile.path)
                                 .map { content in content.replacingFirstOccurrence(of: "<FileRef", with: "\(playgroundRefs.joined(separator: "\n\t"))\n\t<FileRef") }
                                 .flatMap { content in fileSystem.write(content: content, toFile: xcworkspacedataFile.path) }^
                                 .mapError { _ in PlaygroundShellError.linking() }.void()^
            }
        }
        
        let playgroundsNames = EnvIO<FileSystem, PlaygroundShellError, [String]>.var()
        let linkPlaygrounds = EnvIO<FileSystem, PlaygroundShellError, [URL]>.var()
        
        return binding(
            playgroundsNames <- extractPlaygroundsNames(in: xcworkspace),
             linkPlaygrounds <- difference(playgrounds: playgrounds, names: playgroundsNames.get),
                             |<-link(playgrounds: linkPlaygrounds.get, into: xcworkspace),
        yield: ())^
    }
    
    // MARK: - steps
    private func downloadTemplate(into output: URL) -> EnvIO<FileSystem, PlaygroundShellError, URL> {
        func downloadZip(into output: URL) -> EnvIO<FileSystem, PlaygroundShellError, URL> {
            EnvIO.invoke { _ in
                let zip = output.appendingPathComponent("\(Template.name).zip")
                let result = run("curl", args: ["-LkSs", Template.path, "-o", zip.path])
                guard result.exitStatus == 0 else {
                    throw PlaygroundShellError.template(info: result.stderr)
                }
                
                return zip
            }
        }
        
        func unzip(_ zip: URL, into output: URL) -> EnvIO<FileSystem, PlaygroundShellError, URL> {
            EnvIO.invoke { _ in
                let result = run("unzip", args: [zip.path, "-d", output.path])
                guard result.exitStatus == 0 else {
                    throw PlaygroundShellError.template(info: result.stderr)
                }
                
                return output.appendingPathComponent("nef-\(Template.name)")
            }
        }
        
        func removeItem(at item: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
            EnvIO { fileSystem in
                fileSystem.removeDirectory(item.path).mapError { e in .template(info: "\(e)") }
            }
        }
        
        let zip = EnvIO<FileSystem, PlaygroundShellError, URL>.var()
        let template = EnvIO<FileSystem, PlaygroundShellError, URL>.var()
        
        return binding(
                  zip <- downloadZip(into: output),
             template <- unzip(zip.get, into: output),
                      |<-removeItem(at: zip.get),
        yield: template.get)^
    }
    
    private func installTemplate(_ template: URL, name: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO.invoke { _ in
            let script = template.appendingPathComponent("setup").appendingPathComponent("nef.rb")
            let result = run("ruby", args: [script.path, template.path , name])
            guard result.exitStatus == 0 else {
                throw PlaygroundShellError.template(info: result.stderr)
            }
            
            return ()
        }
    }
    
    private func nefPlayground(name: String, fromTemplate template: URL) -> EnvIO<FileSystem, PlaygroundShellError, NefPlaygroundURL> {
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
    
    private func configureLauncher(playground: NefPlaygroundURL, name: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO { fileSystem in
            fileSystem.readFile(atPath: playground.appending(.launcher).path)
                      .map { content in content.replacingOccurrences(of: "{{nef}}", with: name) }
                      .flatMap { content in fileSystem.write(content: content, toFile: playground.appending(.launcher).path) }^
                      .mapError { e in .template(info: "\(e)") }
        }
    }
    
    private func setPlaygroundPlatform(playground: NefPlaygroundURL, platform: Platform) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO { fileSystem in
            guard platform == .ios || platform == .macos else {
                return IO.raiseError(.template(info: "received invalid platform \(platform), you must set platform to 'ios' or 'osx'"))^
            }
            
            let platformFiles = playground.appending(.contentFiles).appendingPathComponent(platform == .ios ? "ios" : "osx")
            let platformDirectory = playground.appending(.contentFiles).appendingPathComponent(platform == .ios ? "osx" : "ios")
            
            let removeOtherPlatformIO = fileSystem.removeDirectory(platformDirectory.path)
            let moveFilesIO = fileSystem.moveFiles(in: platformFiles.path, to: playground.appending(.contentFiles).path)
            
            return removeOtherPlatformIO.followedBy(moveFilesIO)^.mapError { e in .template(info: "\(e)") }
        }
    }
    
    // MARK: dependencies
    private func setDependencies(playground: NefPlaygroundURL, bow: PlaygroundDependencies.Bow) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        func dependency(bow: PlaygroundDependencies.Bow, lastBowVersion: String) -> String {
            switch bow {
            case .version(let version): return "~> \(version.isEmpty ? lastBowVersion : version)"
            case .branch(let branch):   return ":git => '\(Bow.repository)', :branch => '\(branch)'"
            case .tag(let tag):         return ":git => '\(Bow.repository)', :tag => '\(tag)'"
            case .commit(let commit):   return ":git => '\(Bow.repository)', :commit => '\(commit)'"
            }
        }
        
        func updateBowDependency(podfile: URL, with: PlaygroundDependencies.Bow, lastBowVersion: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
            EnvIO { fileSystem in
                let readPodfileIO = fileSystem.readFile(atPath: podfile.path)
                let writeContentIO = { (content: String) in fileSystem.write(content: content, toFile: podfile.path) }
                let setDependencyIO = { (content: String) in content.replacingOccurrences(of: "~> 0.0.0", with: dependency(bow: bow, lastBowVersion: lastBowVersion)) }
                
                return readPodfileIO
                        .map(setDependencyIO)
                        .flatMap(writeContentIO)^
                        .mapError { _ in PlaygroundShellError.dependencies() }
            }
        }
        
        let podfile = playground.appending(filename: "Podfile", in: .contentFiles)
        let lastBowVersion = EnvIO<FileSystem, PlaygroundShellError, String>.var()
        
        return binding(
                           |<-self.checkCocoaPod(),
            lastBowVersion <- self.lastBowVersion(),
                           |<-self.moveFiles(at: playground.appending(.cocoapodsTemplate), into: playground.appending(.contentFiles)),
                           |<-self.cleanTemplates(playground: playground),
                           |<-updateBowDependency(podfile: podfile, with: bow, lastBowVersion: lastBowVersion.get),
                           |<-self.createCocoaPodsWorkspace(playground: playground),
        yield: ())^
    }
    
    private func setDependencies(playground: NefPlaygroundURL, target: String, podfile: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        func updateTarget(podfile: URL, with target: String) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
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
                        .mapError { _ in PlaygroundShellError.dependencies() }
            }
        }
        
        let contentPodfile = playground.appending(filename: "Podfile", in: .contentFiles)
        
        return binding(
            |<-self.checkCocoaPod(),
            |<-self.moveFiles(at: playground.appending(.cocoapodsTemplate), into: playground.appending(.contentFiles)),
            |<-self.cleanTemplates(playground: playground),
            |<-self.rewriteFile(contentPodfile, with: podfile),
            |<-updateTarget(podfile: contentPodfile, with: target),
            |<-self.createCocoaPodsWorkspace(playground: playground),
        yield: ())^
    }
    
    private func setDependencies(playground: NefPlaygroundURL, xcodeproj: URL, cartfile: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        let contentCartfile = playground.appending(filename: "Cartfile", in: .contentFiles)
        
        return binding(
            |<-self.checkCarthage(),
            |<-self.emptyWorkspace(xcodeproj: xcodeproj),
            |<-self.moveFiles(at: playground.appending(.carthageTemplate), into: playground.appending(.contentFiles)),
            |<-self.cleanTemplates(playground: playground),
            |<-self.rewriteFile(contentCartfile, with: cartfile),
        yield: ())^
    }
    
    private func cleanTemplates(playground: NefPlaygroundURL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO { fileSystem in
            let dependencies = [playground.appending(.cocoapodsTemplate),
                                playground.appending(.carthageTemplate)]
            
            return dependencies.traverse { template in fileSystem.removeDirectory(template.path).handleError { _ in } }^
                               .mapError { e in PlaygroundShellError.dependencies(info: "clean templates: \(e)") }
                               .void()
        }
    }
    
    private func emptyWorkspace(xcodeproj: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
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
    private func lastBowVersion() -> EnvIO<FileSystem, PlaygroundShellError, String> {
        EnvIO.invoke { _ in
            let result = run("curl", args: ["--silent", Bow.tags])
            guard result.exitStatus == 0,
                  let lastVersion = result.stdout.matches(pattern: "(?<=name\": \").*(?=\")").first else {
                throw PlaygroundShellError.dependencies(info: result.stderr)
            }
            
            return lastVersion
        }
    }
    
    private func checkCocoaPod() -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO.invoke { _ in
            let result = run("pod", args: ["--version"])
            guard result.exitStatus == 0 else {
                throw PlaygroundShellError.dependencies(info: "Required CocoaPods. Run 'sudo gem install cocoapods'")
            }
            
            return ()
        }
    }
    
    private func checkCarthage() -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO.invoke { _ in
            let result = run("carthage")
            guard result.exitStatus == 0 else {
                throw PlaygroundShellError.dependencies(info: "Required Carthage. Run 'brew install carthage'")
            }
            
            return ()
        }
    }
    
    func createCocoaPodsWorkspace(playground: NefPlaygroundURL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO.invoke { _ in
            let result = run("pod", args: ["install", "--project-directory=\(playground.appending(.contentFiles).path)"])
            guard result.exitStatus == 0 else {
                throw PlaygroundShellError.dependencies(info: "creating xcworkspace using CocoaPods: \(result.stderr) \(result.stdout)")
            }
            
            return ()
        }
    }
    
    // MARK: helpers <file manager>
    private func moveFiles(at input: URL, into output: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO { fileSystem in
            fileSystem.moveFiles(in: input.path, to: output.path).mapError { _ in PlaygroundShellError.dependencies() }
        }
    }
    
    private func rewriteFile(_ file: URL, with newFile: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void> {
        EnvIO { fileSystem in
            let removeOldFileIO = (fileSystem as FileSystem).remove(itemPath: file.path).handleError { _ in }
            let copyNewFileIO = (fileSystem as FileSystem).copy(itemPath: newFile.path, toPath: file.path)
            
            return removeOldFileIO.followedBy(copyNewFileIO)^.mapError { _ in PlaygroundShellError.dependencies() }
        }
    }
    
    // MARK: - Constants
    private enum Template {
        static let path = "https://github.com/bow-swift/nef/archive/\(Template.name).zip"
        static let name = "nefplayground-refactor"
    }
    
    private enum Bow {
        static let tags = "https://api.github.com/repos/bow-swift/bow/tags"
        static let repository = "https://github.com/bow-swift/bow.git"
    }
}
