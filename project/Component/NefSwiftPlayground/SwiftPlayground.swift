//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects
import BowOptics


public struct SwiftPlayground {
    private let resolvePath: PlaygroundResolvePath
    private let packageContent: String
    
    public init(packageContent: String, name: String, output: URL) {
        self.packageContent = packageContent
        self.resolvePath = PlaygroundResolvePath(projectName: name, outputPath: output.path)
    }
    
    public func build(cached: Bool, excludes: [PlaygroundExcludeItem]) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        let modulesRaw = EnvIOPartial<PlaygroundEnvironment, SwiftPlaygroundError>.var([String].self)
        let modules = EnvIOPartial<PlaygroundEnvironment, SwiftPlaygroundError>.var([Module].self)
        
        return binding(
                    |<-self.cleanUp(step: self.step(1), deintegrate: !cached, resolvePath: self.resolvePath),
                    |<-self.structure(step: self.step(2), resolvePath: self.resolvePath),
         modulesRaw <- self.checkout(step: self.step(3), content: self.packageContent, resolvePath: self.resolvePath),
            modules <- self.modules(step: self.step(4), repos: modulesRaw.get, excludes: excludes).contramap(\PlaygroundEnvironment.shell),
                    |<-self.swiftPlayground(step: self.step(5), modules: modules.get, resolvePath: self.resolvePath),
        yield: ())^
    }
    
    // MARK: steps
    private func step(_ number: Int) -> Step { Step(total: 5, partial: number) }
    
    private func cleanUp(step: Step, deintegrate: Bool, resolvePath: PlaygroundResolvePath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Clean up generated files for building"),
                |<-self.removeItem(at: resolvePath.playgroundPath).provide(env.storage),
                |<-self.removeItem(at: resolvePath.packageResolvedPath).provide(env.storage),
                |<-self.removeItem(at: resolvePath.packageFilePath).provide(env.storage),
                |<-self.removeItem(at: resolvePath.buildPath, useCache: !deintegrate).provide(env.storage),
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    private func structure(step: Step, resolvePath: PlaygroundResolvePath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { app in
            binding(
                |<-app.shell.out.printStep(step: step, information: "Creating swift playground structure (\(resolvePath.projectName))"),
                |<-self.makeStructure(buildPath: resolvePath.buildPath).provide(app.storage),
                yield: ())^.reportStatus(step: step, in: app.shell.out, verbose: false)
        }
    }
    
    private func checkout(step: Step, content: String, resolvePath: PlaygroundResolvePath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [String]> {
        let repos = IOPartial<SwiftPlaygroundError>.var([String].self)
        
        return EnvIO { env in
            binding(
                      |<-env.shell.out.printStep(step: step, information: "Downloading dependencies..."),
                      |<-self.buildPackage(content: content, packageFilePath: resolvePath.packageFilePath, packagePath: resolvePath.packagePath, buildPath: resolvePath.buildPath).provide((env.storage, env.shell.run)),
                repos <- self.repositories(checkoutPath: resolvePath.checkoutPath).provide(env.shell.run),
            yield: repos.get)^.reportStatus(step: step, in: env.shell.out, verbose: true)
        }
    }
    
    private func modules(step: Step, repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<Shell, SwiftPlaygroundError, [Module]> {
        let modules = IOPartial<SwiftPlaygroundError>.var([Module].self)
        
        return EnvIO { (console, shell) in
            binding(
                       |<-console.printStep(step: step, information: "Get modules from repositories..."),
               modules <- self.swiftLibraryModules(in: repos, excludes: excludes).provide(shell),
            yield: modules.get)^.reportStatus(step: step, in: console, verbose: true)
        }
    }
    
    private func swiftPlayground(step: Step, modules: [Module], resolvePath: PlaygroundResolvePath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Building Swift Playground..."),
                |<-self.buildPlaygroundBook(modules: modules, playgroundPath: resolvePath.playgroundPath).provide(env.storage),
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    // MARK: steps <helpers>
    private func removeItem(at itemPath: String, useCache: Bool = false) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        guard !useCache else { return EnvIO.pure(())^ }
        
        return EnvIO { storage in
            let removeFileIO = storage.remove(itemPath: itemPath).mapLeft { _ in SwiftPlaygroundError.clean(item: itemPath) }^
            return storage.exist(itemPath: itemPath) ? removeFileIO : IO.pure(())
        }
    }
    
    private func makeStructure(buildPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            storage.createDirectory(atPath: buildPath)^
                   .mapLeft { _ in .structure }
        }
    }
    
    private func buildPackage(content: String, packageFilePath: String, packagePath: String, buildPath: String) -> EnvIO<(FileSystem, PlaygroundShell), SwiftPlaygroundError, Void> {
        EnvIO { (storage, shell) in
            let writePackageIO = storage.write(content: content, toFile: packageFilePath).mapLeft { _ in SwiftPlaygroundError.checkout }
            let resolvePackageIO = shell.resolve(packagePath: packagePath, buildPath: buildPath).mapLeft { _ in SwiftPlaygroundError.checkout }

            return writePackageIO.followedBy(resolvePackageIO)
        }
    }
    
    private func repositories(checkoutPath: String) -> EnvIO<PlaygroundShell, SwiftPlaygroundError, [String]> {
        EnvIO { shell in
            shell.itemPaths(in: checkoutPath).mapLeft { _ in SwiftPlaygroundError.ioError(info: "repositories(checkoutPath:)") }
                 .map { repos in repos.filter { !$0.contains("swift-") } }
                 .handleErrorWith { _ in IO.pure([])^ }
        }
    }
    
    private func swiftLibraryModules(in repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PlaygroundShell, SwiftPlaygroundError, [Module]> {
        func modules(in data: Data) -> [Module] {
            guard let package = try? JSONDecoder().decode(Package.self, from: data) else { return [] }
            
            let modules = package.targets.filter { module in module.type == .library &&
                module.moduleType == .swift &&
                !excludes.contains(.module(name: module.name)) }
            
            return Module.moduleNameAndSourcesTraversal.modify(modules) { (name, sources) in
                (name, sources.filter { file in !excludes.contains(.file(name: file.filename, module: name)) })
            }
        }
        
        func linkPathForSources(in modules: [Module]) -> EnvIO<PlaygroundShell, PlaygroundShellError, [Module]> {
            EnvIO { shell in
                let modules = Module.modulePathAndSourcesTraversal.modify(modules) { (parentPath, sources) in
                    let linkedSources: [String] = sources.map { source in
                        shell.linkPath(itemPath: source, parentPath: parentPath).unsafeRunSyncEither().getOrElse("\(parentPath)/\(source)")
                    }
                    
                    return (parentPath, linkedSources)
                }
                
                return IO.pure(modules)^
            }
        }
        
        return EnvIO { shell in
            repos.flatTraverse { repositoryPath in
                shell.describe(repositoryPath: repositoryPath)
                     .map(modules)^
                     .flatMap { modules in linkPathForSources(in: modules).provide(shell) }^
                     .mapLeft { _ in .modules(repos) }
            }.flatMap { modules in
                modules.count > 0 ? IO.pure(modules)^
                                  : IO.raiseError(.modules(repos))^
            }^
        }
    }
    
    private func buildPlaygroundBook(modules: [Module], playgroundPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { storage in
            PlaygroundBook(name: "nef", path: playgroundPath)
                .build(modules: modules)
                .provide(storage)
                .mapLeft { e in .playgroundBook(info: e.description) }
        }
    }
}
