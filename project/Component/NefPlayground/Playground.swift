//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects

public struct Playground {
    public init() {}
    
    public func build(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        let playground = EnvIO<PlaygroundEnvironment, PlaygroundError, URL>.var()
        
        return binding(
            playground <- self.template(output: output, name: name, platform: platform),
                       |<-self.createStructure(project: playground.get),
        yield: ())^
    }
    
    // MARK: - steps
    private func createStructure(project: URL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { env in
            let cleanRootIO = env.fileSystem.remove(itemPath: NefURL(project: project, action: .root).url.path).handleError { _ in }
            let createLogIO = env.fileSystem.createDirectory(atPath: NefURL(project: project, action: .log).url.path)
            
            return cleanRootIO.followedBy(createLogIO)^.mapError { e in .structure(info: e) }
        }
    }
    
    private func template(output: URL, name: String, platform: Platform) -> EnvIO<PlaygroundEnvironment, PlaygroundError, URL> {
        EnvIO { (env: PlaygroundEnvironment) in
            let playground = IO<PlaygroundError, URL>.var()
            
            return binding(
                           |<-env.console.print(information: "Downloading playground template '\(output.path)'"),
                playground <- env.shell.installTemplate(into: output, name: name, platform: platform).mapError { e in .template(info: e) },
            yield: playground.get)^.reportStatus(console: env.console)
        }
    }
}
    
