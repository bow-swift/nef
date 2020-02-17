//  Copyright © 2020 The nef Authors.

import Foundation
import NefPlayground
import Bow
import BowEffects
import Swiftline

class MacPlaygroundShell: PlaygroundShell {
    let fileSystem = FileManager.default
    
    func downloadTemplate(into output: URL, name: String, platform: Platform) -> IO<PlaygroundShellError, URL> {
        downloadPlaygroundTemplate(into: output, name: name)
    }
    
    private func downloadPlaygroundTemplate(into output: URL, name: String) -> IO<PlaygroundShellError, URL> {
        func downloadZip(into output: URL) -> IO<PlaygroundShellError, URL> {
            IO.invoke {
                let zip = output.appendingPathComponent("master.zip")
                let result = run("curl", args: ["-LkSs", Path.template, "-o", zip.path])
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
                
                return output.appendingPathComponent("nef-master")
            }
        }
        
        func deleteZip(_ zip: URL) -> IO<PlaygroundShellError, Void> {
            fileSystem.removeItemIO(at: zip).mapError { _ in .template() }
        }
        
        func installTemplate(_ template: URL, name: String) -> IO<PlaygroundShellError, Void> {
            IO.invoke {
                let script = template.appendingPathComponent("setup").appendingPathComponent("nef.rb")
                let result = run("ruby", args: [template.path, script.path , name])
                guard result.exitStatus == 0 else {
                    throw PlaygroundShellError.template(info: result.stderr)
                }
                
                return ()
            }
        }
        
        let zip = IO<PlaygroundShellError, URL>.var()
        let template = IO<PlaygroundShellError, URL>.var()
        let project = IO<PlaygroundShellError, URL>.var()
        
        return binding(
                 zip <- downloadZip(into: output),
            template <- unzip(zip.get, into: output),
                     |<-deleteZip(zip.get),
                     |<-installTemplate(template.get, name: name),
        yield: project.get)^
    }
    
    enum Path {
        static let bowTags = "https://api.github.com/repos/bow-swift/bow/tags"
        static let template = "https://github.com/bow-swift/nef/archive/master.zip"
    }
}
