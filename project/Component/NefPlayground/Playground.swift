//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects

public struct Playground {
    public init() {}
    
    public func build(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        let playground = EnvIO<PlaygroundEnvironment, PlaygroundError, NefPlaygroundURL>.var()
        
        return binding(
               playground <- self.template(output: output, name: name, platform: platform),
                          |<-self.createStructure(playground: playground.get),
                          |<-self.resolveDependencies(dependencies, playground: playground.get, name: name),
        yield: ())^
    }
    
    // MARK: - steps
    private func template(output: URL, name: String, platform: Platform) -> EnvIO<PlaygroundEnvironment, PlaygroundError, NefPlaygroundURL> {
        EnvIO { env in
            let playground = IO<PlaygroundError, NefPlaygroundURL>.var()
            
            return binding(
                           |<-env.console.print(information: "Downloading playground template '\(output.path)'"),
                playground <- env.shell.installTemplate(into: output, name: name, platform: platform).provide(env.fileSystem).mapError { e in .template(info: e) },
            yield: playground.get)^.reportStatus(console: env.console)
        }
    }
    
    private func createStructure(playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { env in
            let cleanRootIO = env.fileSystem.remove(itemPath: playground.appending(.nef).path).handleError { _ in }
            let createLogIO = env.fileSystem.createDirectory(atPath: playground.appending(.log).path)
            
            return cleanRootIO.followedBy(createLogIO)^.mapError { e in .structure(info: e) }
        }
    }
    
    private func resolveDependencies(_ dependencies: PlaygroundDependencies, playground: NefPlaygroundURL, name: String) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.print(information: "Resolving nef playground '\(name)' dependencies"),
                |<-env.shell.setDependencies(dependencies, playground: playground, target: name).provide(env.fileSystem).mapError { e in .template(info: e) },
            yield: ())^.reportStatus(console: env.console)
        }
    }
}
    
