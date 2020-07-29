//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects

public struct Playground {
    public init() {}
    
    public func build(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<PlaygroundEnvironment, PlaygroundError, URL> {
        let name = playgroundName(name)
        let nefPlayground = EnvIO<PlaygroundEnvironment, PlaygroundError, NefPlaygroundURL>.var()
        
        return binding(
            nefPlayground <- self.template(output: output, name: name, platform: platform),
                          |<-self.createStructure(playground: nefPlayground.get),
                          |<-self.setDependencies(dependencies, playground: nefPlayground.get, name: name),
                          |<-self.linkPlaygrounds(nefPlayground.get),
        yield: nefPlayground.get.project)^
    }
    
    public func build(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<PlaygroundEnvironment, PlaygroundError, URL> {
        let name = playgroundName(name)
        let nefPlayground = EnvIO<PlaygroundEnvironment, PlaygroundError, NefPlaygroundURL>.var()
        
        return binding(
            nefPlayground <- self.template(output: output, name: name, platform: platform),
                          |<-self.createStructure(playground: nefPlayground.get),
                          |<-self.setDependencies(dependencies, playground: nefPlayground.get, name: name),
                          |<-self.setNefPlayground(nefPlayground.get, withXcodePlayground: xcodePlayground, name: name),
                          |<-self.linkPlaygrounds(nefPlayground.get),
        yield: nefPlayground.get.project)^
    }
    
    // MARK: - steps
    private func template(output: URL, name: String, platform: Platform) -> EnvIO<PlaygroundEnvironment, PlaygroundError, NefPlaygroundURL> {
        EnvIO { env in
            let playground = IO<PlaygroundError, NefPlaygroundURL>.var()
            let step = PlaygroundEvent.downloadingTemplate(output.path)
            
            return binding(
                          |<-env.progressReport.inProgress(step),
                playground <- env.nefPlaygroundSystem.installTemplate(into: output,
                                                                      name: name,
                                                                      platform: platform).provide(env.fileSystem)
                                                                                         .mapError { e in .template(info: e) },
            yield: playground.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func createStructure(playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { env in
            let cleanRootIO = env.fileSystem.remove(itemPath: playground.appending(.nef).path).handleError { _ in }
            let createLogIO = env.fileSystem.createDirectory(atPath: playground.appending(.log).path)
            
            return cleanRootIO.followedBy(createLogIO)^.mapError { e in .structure(info: e) }
        }
    }
    
    private func setDependencies(_ dependencies: PlaygroundDependencies, playground: NefPlaygroundURL, name: String) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        func xcodeprojAt(_ playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, URL> {
            EnvIO { env in
                env.xcodePlaygroundSystem.xcodeprojs(at: playground.appending(.contentFiles)).provide(env.fileSystem)
                                         .map { xcworkspaces in xcworkspaces.head }^
                                         .mapError { e in .dependencies(info: e) }
            }
        }
        
        let xcodeproj = IO<PlaygroundError, URL>.var()
        let step = PlaygroundEvent.resolvingDependencies(name)
        
        return EnvIO { env in
            binding(
                |<-env.progressReport.inProgress(step),
                xcodeproj <- xcodeprojAt(playground).provide(env),
                |<-env.nefPlaygroundSystem.setDependencies(
                    dependencies,
                    playground: playground,
                    inXcodeproj: xcodeproj.get,
                    target: name)
                    .provide(env.fileSystem)
                    .mapError { e in .dependencies(info: e) },
                yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func setNefPlayground(_ nefPlayground: NefPlaygroundURL, withXcodePlayground xcodePlayground: URL, name: String) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        binding(
            |<-self.removePlaygrounds(in: nefPlayground).handleError { _ in },
            |<-self.move(playground: xcodePlayground, to: nefPlayground, name: name),
        yield: ())^
    }
    
    private func linkPlaygrounds(_ playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        func xcworkspaceAt(_ playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, URL> {
            EnvIO { env in
                env.xcodePlaygroundSystem.xcworkspaces(at: playground.appending(.contentFiles)).provide(env.fileSystem)
                    .map { xcworkspaces in xcworkspaces.head }^
                    .mapError { e in .template(info: e) }
            }
        }
        
        func playgrounsAt(_ playground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, NEA<URL>> {
            EnvIO { env in
                env.xcodePlaygroundSystem.playgrounds(at: playground.appending(.contentFiles)).provide(env.fileSystem)
                    .mapError { e in .template(info: e) }
            }
        }
        
        func linkPlaygrounds(_ playgrounds: NEA<URL>, xcworkspace: URL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
            EnvIO { env in
                env.nefPlaygroundSystem.linkPlaygrounds(playgrounds, xcworkspace: xcworkspace).provide(env.fileSystem)
                    .mapError { e in .template(info: e) }
            }
        }
        
        return EnvIO { env in
            let xcworkspace = IO<PlaygroundError, URL>.var()
            let playgrounds = IO<PlaygroundError, NEA<URL>>.var()
            let step = PlaygroundEvent.linkingPlaygrounds(playground.name)
            
            return binding(
                           |<-env.progressReport.inProgress(step),
                xcworkspace <- xcworkspaceAt(playground).provide(env),
                playgrounds <- playgrounsAt(playground).provide(env),
                           |<-linkPlaygrounds(playgrounds.get, xcworkspace: xcworkspace.get).provide(env),
            yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    // MARK: helpers
    private func removePlaygrounds(in nefPlayground: NefPlaygroundURL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        func findPlaygrounds(in folder: URL) -> EnvIO<PlaygroundEnvironment, PlaygroundError, NEA<URL>> {
            EnvIO { env in
                env.xcodePlaygroundSystem
                   .playgrounds(at: folder)
                   .provide(env.fileSystem)
                   .mapError { e in PlaygroundError.operation(operation: "find playgrounds", info: e) }
            }
        }
        
        func removePlaygrouds(_ playgrounds: NEA<URL>) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
            EnvIO { env in
                return playgrounds.traverse { playground in env.fileSystem.remove(itemPath: playground.path) }^
                                  .mapError { e in PlaygroundError.operation(operation: "remove playgrounds", info: e) }
                                  .void()
            }
        }
        
        let playgrounds = EnvIO<PlaygroundEnvironment, PlaygroundError, NEA<URL>>.var()
        
        return binding(
            playgrounds <- findPlaygrounds(in: nefPlayground.appending(.contentFiles)),
                        |<-removePlaygrouds(playgrounds.get),
        yield: ())^
    }
    
    private func move(playground: URL, to nefPlayground: NefPlaygroundURL, name: String) -> EnvIO<PlaygroundEnvironment, PlaygroundError, Void> {
        EnvIO { env in
            env.fileSystem.copy(itemPath: playground.path, toPath: nefPlayground.appending(.contentFiles).appendingPathComponent("\(name).playground").path)
                .mapError { e in PlaygroundError.operation(operation: "move playground into nef Playground", info: e) }
        }
    }
    
    private func playgroundName(_ name: String) -> String {
        name.components(separatedBy: " ")
            .map { $0.firstCapitalized }
            .joined()
            .trimmingEmptyCharacters
    }
}
