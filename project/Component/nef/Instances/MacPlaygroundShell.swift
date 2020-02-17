//  Copyright © 2020 The nef Authors.

import Foundation
import NefPlayground
import Bow
import BowEffects
import Swiftline

class MacPlaygroundShell: PlaygroundShell {
    let fileSystem: FileSystem
    
    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }
    
    func installTemplate(into output: URL, name: String, platform: Platform) -> IO<PlaygroundShellError, URL> {
        let template = IO<PlaygroundShellError, URL>.var()
        let playground = IO<PlaygroundShellError, URL>.var()
        
        return binding(
            template <- self.downloadTemplate(into: output),
                     |<-self.installTemplate(template.get, name: name),
          playground <- self.makePlayground(template: template.get, name: name),
                     |<-self.setPlaygroundPlatform(playground: playground.get, platform: platform),
                     |<-self.configureLauncher(nefPlayground: playground.get, name: name),
        yield: playground.get)^
    }
    
    // MARK: - steps
    private func downloadTemplate(into output: URL) -> IO<PlaygroundShellError, URL> {
        func downloadZip(into output: URL) -> IO<PlaygroundShellError, URL> {
            IO.invoke {
                let zip = output.appendingPathComponent("\(Template.name).zip")
                let result = run("curl", args: ["-LkSs", Template.path, "-o", zip.path])
                guard result.exitStatus == 0 else {
                    throw PlaygroundShellError.template(info: result.stderr)
                }
                
                return zip
            }
        }
        
        func unzip(_ zip: URL, into output: URL) -> IO<PlaygroundShellError, URL> {
            IO.invoke {
                let result = run("unzip", args: [zip.path, "-d", output.path])
                guard result.exitStatus == 0 else {
                    throw PlaygroundShellError.template(info: result.stderr)
                }
                
                return output.appendingPathComponent("nef-\(Template.name)")
            }
        }
        
        func removeItem(at item: URL) -> IO<PlaygroundShellError, Void> {
            fileSystem.removeDirectory(item.path).mapError { e in .template(info: "\(e)") }
        }
        
        let zip = IO<PlaygroundShellError, URL>.var()
        let template = IO<PlaygroundShellError, URL>.var()
        
        return binding(
                  zip <- downloadZip(into: output),
             template <- unzip(zip.get, into: output),
                      |<-removeItem(at: zip.get),
        yield: template.get)^
    }
    
    private func installTemplate(_ template: URL, name: String) -> IO<PlaygroundShellError, Void> {
        IO.invoke {
            let script = template.appendingPathComponent("setup").appendingPathComponent("nef.rb")
            let result = run("ruby", args: [script.path, template.path , name])
            guard result.exitStatus == 0 else {
                throw PlaygroundShellError.template(info: result.stderr)
            }
            
            return ()
        }
    }
    
    private func makePlayground(template: URL, name: String) -> IO<PlaygroundShellError, URL> {
        let templateApp = template.appendingPathComponent("\(name).app")
        let app = template.deletingLastPathComponent().appendingPathComponent("\(name).app")
        let appContent = app.appendingPathComponent("Contents").appendingPathComponent("MacOS")
        
        let moveAppIO = fileSystem.moveFile(from: templateApp.path, to: app.path)
        let moveTemplateFilesIO = fileSystem.moveFiles(in: template.path, to: appContent.path)
        
        return moveAppIO.followedBy(moveTemplateFilesIO)^
                .mapError { e in .template(info: "\(e)") }
                .map { app }^
    }
    
    private func configureLauncher(nefPlayground playground: URL, name: String) -> IO<PlaygroundShellError, Void> {
        let launcher = playground.appendingPathComponent("Contents").appendingPathComponent("MacOS").appendingPathComponent("launcher")
        
        return fileSystem.readFile(atPath: launcher.path)
                         .map { content in content.replacingOccurrences(of: "{{nef}}", with: name) }
                         .flatMap { content in self.fileSystem.write(content: content, toFile: launcher.path) }^
                         .mapError { e in .template(info: "\(e)") }
        
    }
    
    private func setPlaygroundPlatform(playground: URL, platform: Platform) -> IO<PlaygroundShellError, Void> {
        guard platform == .ios || platform == .macos else {
            return IO.raiseError(.template(info: "received invalid platform \(platform)"))^
        }
        
        let contentFiles = playground.appendingPathComponent("Contents").appendingPathComponent("MacOS")
        let platformFiles = contentFiles.appendingPathComponent(platform == .ios ? "ios" : "osx")
        let platformDirectory = contentFiles.appendingPathComponent(platform == .ios ? "osx" : "ios")
        
        let removeOtherPlatformIO = fileSystem.removeDirectory(platformDirectory.path)
        let moveFilesIO = fileSystem.moveFiles(in: platformFiles.path, to: contentFiles.path)
        
        return removeOtherPlatformIO.followedBy(moveFilesIO)^.mapError { e in .template(info: "\(e)") }
    }
    
    // MARK: - Constants
    enum Template {
        static let path = "https://github.com/bow-swift/nef/archive/\(Template.name).zip"
        static let name = "nefplayground-refactor"
    }
    
    enum Bow {
        static let tags = "https://api.github.com/repos/bow-swift/bow/tags"
    }
}
