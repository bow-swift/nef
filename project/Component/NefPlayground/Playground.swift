//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects

public struct Playground {
    public init() {}
    
    public func build(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        binding(
            |<-self.downloadTemplate(output: output, name: name, platform: platform),
//            |<-self.createStructure(project: project),
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
    
    private func downloadTemplate(output: URL, name: String, platform: Platform) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { (env: PlaygroundEnvironment) in
            binding(
                |<-env.console.print(information: "Downloading playground template '\(output.path)'"),
                |<-env.shell.downloadTemplate(into: output, name: name, platform: platform).mapError { e in .template(info: e) },
            yield: ())^.reportStatus(console: env.console)
        }
    }
}
    
