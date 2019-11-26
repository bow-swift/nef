//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Swiftline

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
        let modulesRaw = EnvIOPartial<iPadApp, SwiftPlaygroundError>.var([String].self)
        let modules = EnvIOPartial<iPadApp, SwiftPlaygroundError>.var([Module].self)
        
        return binding(
                    |<-self.cleanUp(step: self.step(1), deintegrate: !cached, resolvePath: self.resolvePath),
                    |<-self.structure(step: self.step(2), resolvePath: self.resolvePath),
         modulesRaw <- self.checkout(step: self.step(3), content: self.packageContent, resolvePath: self.resolvePath),
            modules <- self.modules(step: self.step(4), repos: modulesRaw.get).contramap(\iPadApp.console),
//                       |<-self.stepPlayground(modules: modules.get, resolvePath: resolvePath),
        yield: ())^
    }
    
    // MARK: steps
    private func step(_ number: Int) -> Step { Step(total: 6, partial: number) }
    
    private func cleanUp(step: Step, deintegrate: Bool, resolvePath: ResolvePath) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
        EnvIO { app in
            binding(
                |<-app.console.printStep(step: step, information: "Clean up generated files for building"),
                |<-self.removePackageFile(at: resolvePath.packageResolvedPath).provide(app.storage),
                |<-self.removePackageFile(at: resolvePath.packageFilePath).provide(app.storage),
                |<-self.removeBuildFolder(at: resolvePath.buildPath, shouldDeintegrate: deintegrate).provide(app.storage),
            yield: ())^.reportStatus(step: step, in: app.console, verbose: false)
        }
    }
    
    private func structure(step: Step, resolvePath: ResolvePath) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
        EnvIO { app in
            binding(
                |<-app.console.printStep(step: step, information: "Creating swift playground structure (\(resolvePath.projectName))"),
                |<-self.makeStructure(buildPath: resolvePath.buildPath).provide(app.storage),
            yield: ())^.reportStatus(step: step, in: app.console, verbose: false)
        }
    }
    
    private func checkout(step: Step, content: String, resolvePath: ResolvePath) -> EnvIO<iPadApp, SwiftPlaygroundError, [String]> {
        let repos = IOPartial<SwiftPlaygroundError>.var([String].self)
        
        return EnvIO { app in
            binding(
                      |<-app.console.printStep(step: step, information: "Downloading dependencies..."),
                      |<-self.buildPackage(content: content, packageFilePath: resolvePath.packageFilePath, packagePath: resolvePath.packagePath, buildPath: resolvePath.buildPath).provide(app.storage),
                repos <- self.repositories(checkoutPath: resolvePath.checkoutPath),
            yield: repos.get)^.reportStatus(step: step, in: app.console, verbose: true)
        }
    }
    
    private func modules(step: Step, repos: [String]) -> EnvIO<Console, SwiftPlaygroundError, [Module]> {
        let modules = IOPartial<SwiftPlaygroundError>.var([Module].self)
        
        return EnvIO { console in
            binding(
                       |<-console.printStep(step: step, information: "Get modules from repositories..."),
               modules <- self.swiftLibraryModules(in: repos),
            yield: modules.get)^.reportStatus(step: step, in: console, verbose: true)
        }
    }
    
    // MARK: steps <helpers>
    private func removePackageFile(at filePath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            let removeFileIO = storage.remove(itemPath: filePath).mapLeft { _ in SwiftPlaygroundError.clean(item: filePath) }^
            return storage.exist(itemPath: filePath) ? removeFileIO : IO.pure(())
        }
    }
    
    private func removeBuildFolder(at path: String, shouldDeintegrate deintegrate: Bool) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        guard deintegrate else { return EnvIO.pure(())^ }
        
        return EnvIO { storage in
            storage.remove(itemPath: path)^
                   .mapLeft { _ in .clean(item: path) }
        }
    }
    
    private func makeStructure(buildPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            storage.createDirectory(atPath: buildPath)^
                   .mapLeft { _ in .structure }
        }
    }
    
    private func buildPackage(content: String, packageFilePath: String, packagePath: String, buildPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            storage.write(content: content, toFile: packageFilePath)^
                   .map { void -> Bool in
                          let result = run("swift package --package-path \(packagePath) --build-path \(buildPath) resolve")
                          return result.exitStatus == 0 }^
                   .mapLeft { _ in SwiftPlaygroundError.checkout }
                   .flatMap { status in !status ? IO.raiseError(.checkout)
                                                : IO.pure(()) }
        }
    }
    
    private func repositories(checkoutPath: String) -> IO<SwiftPlaygroundError, [String]> {
        let result = run("ls \(checkoutPath)")
        guard result.exitStatus == 0 else { return IO.pure([])^ }
        
        let repositoriesPath = result.stdout.components(separatedBy: "\n").map { "\(checkoutPath)/\($0)" }
        let repos = repositoriesPath.filter { !$0.contains("swift-") }
        return IO.pure(repos)^
    }
    
    private func swiftLibraryModules(in repos: [String]) -> IO<SwiftPlaygroundError, [Module]> {
        let modules = repos.flatMap { repositoryPath -> [Module] in
            let result = run("swift package --package-path \(repositoryPath) describe --type json")
            guard result.exitStatus == 0,
                  !result.stdout.isEmpty,
                  let data = result.stdout.data(using: .utf8),
                  let package = try? JSONDecoder().decode(Package.self, from: data) else { return [] }
            
            return package.targets.filter { module in module.type == .library &&
                                                      module.moduleType == .swift }
        }
        
        return modules.count > 0 ? IO.pure(modules)^
                                 : IO.raiseError(.modules(repos))^
    }
}
