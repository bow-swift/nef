//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels

import Bow
import BowEffects
import BowOptics

public struct SwiftPlayground {
    private let resolutionPath: PlaygroundResolutionPath
    private let packageContent: String
    
    public init(packageContent: String, name: String, output: URL) {
        self.packageContent = packageContent
        self.resolutionPath = PlaygroundResolutionPath(projectName: name, outputPath: output.path)
    }
    
    public func build(cached: Bool, excludes: [PlaygroundExcludeItem]) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        let modulesRaw = EnvIOPartial<PlaygroundEnvironment, SwiftPlaygroundError>.var([String].self)
        let modules = EnvIOPartial<PlaygroundEnvironment, SwiftPlaygroundError>.var([Module].self)
        
        return binding(
                    |<-self.cleanUp(step: self.step(1), deintegrate: !cached, path: self.resolutionPath),
                    |<-self.structure(step: self.step(2), path: self.resolutionPath),
         modulesRaw <- self.checkout(step: self.step(3, duration: .seconds(20)), content: self.packageContent, path: self.resolutionPath),
            modules <- self.modules(step: self.step(4, duration: .seconds(5)), repos: modulesRaw.get, excludes: excludes).contramap(\PlaygroundEnvironment.shell),
                    |<-self.swiftPlayground(step: self.step(5), modules: modules.get, path: self.resolutionPath),
        yield: ())^
    }
    
    // MARK: steps
    private func step(_ number: UInt, duration: DispatchTimeInterval = .seconds(3)) -> Step { Step(total: 5, partial: number, duration: duration) }
    
    private func cleanUp(step: Step, deintegrate: Bool, path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Clean up generated files for building"),
                |<-self.removeItem(at: path.playgroundPath).provide(env.system),
                |<-self.removeItem(at: path.packageResolvedPath).provide(env.system),
                |<-self.removeItem(at: path.packageFilePath).provide(env.system),
                |<-self.removeItem(at: path.buildPath, useCache: !deintegrate).provide(env.system),
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    private func structure(step: Step, path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Creating swift playground structure (\(path.projectName))"),
                |<-self.makeStructure(buildPath: path.buildPath).provide(env.system),
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    private func checkout(step: Step, content: String, path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [String]> {
        EnvIO { env in
            let repos = IOPartial<SwiftPlaygroundError>.var([String].self)
            
            return binding(
                      |<-env.shell.out.printStep(step: step, information: "Downloading dependencies..."),
                      |<-self.buildPackage(content: content, packageFilePath: path.packageFilePath, packagePath: path.packagePath, buildPath: path.buildPath).provide((env.system, env.shell.run)),
                repos <- self.repositories(checkoutPath: path.checkoutPath).provide(env.system),
            yield: repos.get)^.reportStatus(step: step, in: env.shell.out, verbose: true)
        }
    }
    
    private func modules(step: Step, repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<Shell, SwiftPlaygroundError, [Module]> {
        EnvIO { (out, shell) in
            let modules = IOPartial<SwiftPlaygroundError>.var([Module].self)
            
            return binding(
                       |<-out.printStep(step: step, information: "Get modules from repositories..."),
               modules <- self.swiftLibraryModules(in: repos, excludes: excludes).provide(shell),
            yield: modules.get)^.reportStatus(step: step, in: out, verbose: true)
        }
    }
    
    private func swiftPlayground(step: Step, modules: [Module], path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Building Swift Playground..."),
                |<-self.buildPlaygroundBook(modules: modules, playgroundPath: path.playgroundPath).provide(env.system),
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    // MARK: steps <helpers>
    private func removeItem(at itemPath: String, useCache: Bool = false) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { system in
            guard !useCache else { return IO.pure(()) }
            
            let removeFileIO = system.remove(itemPath: itemPath).mapError { _ in SwiftPlaygroundError.clean(item: itemPath) }^
            return system.exist(itemPath: itemPath) ? removeFileIO : IO.pure(())
        }
    }
    
    private func makeStructure(buildPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        EnvIO { system in
            system.createDirectory(atPath: buildPath)^
                  .mapError { _ in .structure }
        }
    }
    
    private func buildPackage(content: String, packageFilePath: String, packagePath: String, buildPath: String) -> EnvIO<(FileSystem, PackageShell), SwiftPlaygroundError, Void> {
        EnvIO { (system, shell) in
            let writePackageIO = system.write(content: content, toFile: packageFilePath).mapError { e in SwiftPlaygroundError.checkout(info: e.description) }
            let resolvePackageIO = shell.resolve(packagePath: packagePath, buildPath: buildPath).mapError { e in SwiftPlaygroundError.checkout(info: e.description) }

            return writePackageIO.followedBy(resolvePackageIO)
        }
    }
    
    private func repositories(checkoutPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, [String]> {
        EnvIO { fileSystem in
            fileSystem.items(atPath: checkoutPath, recursive: false)
                      .mapError { e in .checkout(info: e.description) }
                      .map { repos in repos.filter { repo in !repo.filename.contains("swift-") } }
        }
    }
    
    private func swiftLibraryModules(in repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
        func modules(in data: Data) -> [Module] {
            guard let package = try? JSONDecoder().decode(Package.self, from: data) else { return [] }
            
            let modules = package.targets.filter { module in module.type == .library &&
                                                             module.moduleType == .swift &&
                                                            !excludes.contains(.module(name: module.name)) }
            
            return Module.moduleNameAndSourcesTraversal.modify(modules) { (name, sources) in
                (name, sources.filter { file in !excludes.contains(.file(name: file.filename, module: name)) })
            }
        }
        
        func linkPathForSources(in modules: [Module]) -> EnvIO<PackageShell, PackageShellError, [Module]> {
            EnvIO { shell in
                modules.traverse { (module: Module) in
                    let sourcesIO = module.sources.map { ($0, module.path) }.traverse(shell.linkPath)^
                    let moduleIO  = sourcesIO.map { sources in
                        Module.sourcesLens.set(module, sources)
                    }^
                    
                    return moduleIO
                }
            }
        }
        
        return EnvIO { shell in
            repos.parFlatTraverse { repositoryPath in
                shell.describe(repositoryPath: repositoryPath)
                     .map(modules)^
                     .flatMap { modules in linkPathForSources(in: modules).provide(shell) }^
                     .mapError { _ in .modules(repos) }
            }.flatMap { modules in
                modules.count > 0 ? IO.pure(modules)^
                                  : IO.raiseError(.modules(repos))^
            }^
        }
    }
    
    private func buildPlaygroundBook(modules: [Module], playgroundPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        PlaygroundBook(name: "nef", path: playgroundPath)
            .build(modules: modules)
            .mapError { e in .playgroundBook(info: e.description) }
    }
}
