//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Bow
import BowEffects


public struct SwiftPlayground {
    private let resolvePath: ResolvePath
    private let packageContent: String
    
    public init(packageContent: String, name: String, output: URL) {
        self.packageContent = packageContent
        self.resolvePath = ResolvePath(projectName: name, outputPath: output.path)
    }
    
    public func build(cached: Bool) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
//        let modulesRaw = EnvIOPartial<iPadApp, SwiftPlaygroundError>.var([String].self)
//        let modules = EnvIOPartial<iPadApp, SwiftPlaygroundError>.var([Module].self)
        
        return binding(
                    |<-self.stepCleanUp(step: self.step(number: 1), deintegrate: !cached, resolvePath: self.resolvePath),
                    |<-self.stepStructure(step: self.step(number: 2), resolvePath: self.resolvePath),
//            modulesRaw <- self.stepChekout(resolvePath: resolvePath),
//            modules    <- self.stepGetModules(fromRepositories: modulesRaw.get).contramap(\IPadApp.console),
//                       |<-self.stepPlayground(modules: modules.get, resolvePath: resolvePath),
//                       |<-self.stepCleanUp(deintegrate: false, resolvePath: resolvePath),
        yield: ())^
    }
    
    // MARK: steps
    private func step(number: Int) -> Step { Step(total: 6, partial: number) }
    
    private func stepCleanUp(step: Step, deintegrate: Bool, resolvePath: ResolvePath) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
        EnvIO { app in
            binding(
                |<-app.console.printStep(step: step, information: "Clean up generated files for building"),
                |<-self.removePackageResolved(resolvePath: resolvePath).provide(app.storage),
                |<-self.removeBuildFolder(resolvePath: resolvePath, shouldDeintegrate: deintegrate).provide(app.storage),
            yield: ())^.reportStatus(step: step, in: app.console)
        }
    }
    
    private func stepStructure(step: Step, resolvePath: ResolvePath) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
        EnvIO { app in
            binding(
                |<-app.console.printStep(step: step, information: "Creating swift playground structure (\(resolvePath.projectName))"),
                |<-self.makeStructure(projectPath: resolvePath.projectPath, buildPath: resolvePath.buildPath).provide(app.storage),
            yield: ())^.reportStatus(step: step, in: app.console)
        }
    }
    
    // MARK: steps <helpers>
    private func removePackageResolved(resolvePath: ResolvePath) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            storage.remove(itemPath: resolvePath.packageResolvedPath)^
                   .mapLeft { _ in .clean(item: resolvePath.packageResolvedPath) }
        }
    }
    
    private func removeBuildFolder(resolvePath: ResolvePath, shouldDeintegrate deintegrate: Bool) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        guard deintegrate else { return EnvIO { _ in IO.pure(())^ } }
        
        return EnvIO { storage in
            storage.remove(itemPath: resolvePath.nefPath)^
                   .mapLeft { _ in .clean(item: resolvePath.nefPath) }
        }
    }
    
    private func makeStructure(projectPath: String, buildPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            storage.createDirectory(atPath: projectPath)^
                   .mapLeft { _ in .structure }
        }
    }
}
