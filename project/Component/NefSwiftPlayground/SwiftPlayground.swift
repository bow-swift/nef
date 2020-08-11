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
        let modulesRaw = EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [String]>.var()
        let modules = EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [Module]>.var()
        
        return binding(
                      |<-self.cleanUp(deintegrate: !cached, path: self.resolutionPath),
                      |<-self.structure(path: self.resolutionPath),
           modulesRaw <- self.checkout(content: self.packageContent, path: self.resolutionPath),
              modules <- self.modules(repos: modulesRaw.get, excludes: excludes),
                      |<-self.swiftPlayground(modules: modules.get, path: self.resolutionPath),
        yield: ())^
    }
    
    // MARK: - Steps
    private func cleanUp(deintegrate: Bool, path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            let step = PlaygroundBookEvent.cleanup
            
            return binding(
                |<-env.progressReport.inProgress(step),
                |<-self.removeItem(at: path.playgroundPath).provide(env.system),
                |<-self.removeItem(at: path.packageResolvedPath).provide(env.system),
                |<-self.removeItem(at: path.packageFilePath).provide(env.system),
                |<-self.removeItem(at: path.buildPath, useCache: !deintegrate).provide(env.system),
            yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func structure(path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            let step = PlaygroundBookEvent.creatingStructure(path.projectName)
            
            return binding(
                |<-env.progressReport.inProgress(step),
                |<-self.makeStructure(buildPath: path.buildPath).provide(env.system),
            yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func checkout(content: String, path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [String]> {
        EnvIO { env in
            let repos = IOPartial<SwiftPlaygroundError>.var([String].self)
            let step = PlaygroundBookEvent.downloadingDependencies
            
            return binding(
                     |<-env.progressReport.inProgress(step),
                     |<-self.buildPackage(content: content, packageFilePath: path.packageFilePath, packagePath: path.packagePath, buildPath: path.buildPath)
                            .provide((env.system, env.shell)),
               repos <- self.repositories(checkoutPath: path.checkoutPath).provide(env.system),
            yield: repos.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func modules(repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [Module]> {
        EnvIO { env in
            let modules = IO<SwiftPlaygroundError, [Module]>.var()
            let step = PlaygroundBookEvent.gettingModules
            
            return binding(
                        |<-env.progressReport.inProgress(step),
                modules <- self.swiftLibraryModules(in: repos, excludes: excludes).provide(env.shell),
            yield: modules.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func swiftPlayground(modules: [Module], path: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, Void> {
        EnvIO { env in
            let step = PlaygroundBookEvent.buildingPlayground
            
            return binding(
                |<-env.progressReport.inProgress(step),
                |<-self.buildPlaygroundBook(modules: modules, playgroundPath: path.playgroundPath).provide(env.system),
            yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    // MARK: - Steps <helpers>
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
        }
    }
    
    private func packageGraph(packagePath: String) -> EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]> {
        func productsDescription(swiftPackage: SwiftPackage) -> EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]> {
            let products = swiftPackage.products.filter { $0.type == .library }
            let packageGraph = products.map { product -> SwiftPackageProduct in
                let dependencies = swiftPackage.targets
                    .filter { target in product.targets.contains(target.name) }
                    .map(\.dependencies)
                    .flatMap { $0.targets + $0.products }
                    .removeDuplicates()
                
                return .init(name: product.name, dependencies: dependencies)
            }
            
            return EnvIO.pure(packageGraph)^
        }
        
        let env =  EnvIO<PackageShell, SwiftPlaygroundError, PackageShell>.var()
        let package = EnvIO<PackageShell, SwiftPlaygroundError, SwiftPackage>.var()
        let products = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
        
        return binding(
                 env <- .ask(),
             package <- env.get.dumpPackage(packagePath: packagePath).mapError(SwiftPlaygroundError.dumpPackage).env(),
            products <- productsDescription(swiftPackage: package.get),
        yield: products.get)^
    }
    
    private func swiftLibraryModules(in repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
        func modules(inRepos repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            let products = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
            let reposModules = EnvIO<PackageShell, SwiftPlaygroundError, [Module]>.var()
            let productsModules = EnvIO<PackageShell, SwiftPlaygroundError, [Module]>.var()
            let modulesInPackage = curry(flip(modules(packagePath:excludes:)))(excludes)
            
            return binding(
                      products <- repos.parFlatTraverse(self.packageGraph(packagePath:))^,
                  reposModules <- repos.parFlatTraverse(modulesInPackage)^,
               productsModules <- filterModules(reposModules.get, inProducts: products.get),
            yield: productsModules.get)^
        }
        
        func modules(packagePath: String, excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            EnvIO { shell in
                shell.describe(repositoryPath: packagePath)
                     .map { data in
                        modules(in: data, excludes: excludes)
                        
                    }^
                     .flatMap { modules in
                        linkPathForSources(in: modules).provide(shell)
                        
                    }^
                     .mapError { _ in .modules(repos) }
            }
        }
        
        func modules(in data: Data, excludes: [PlaygroundExcludeItem]) -> [Module] {
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
        
        func filterModules(_ modules: [Module], inProducts products: [SwiftPackageProduct]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            EnvIO.access { _ in 
                let modulesNames = Set(modules.map(\.name))
                let validProductsNames = products.filter { product in modulesNames.isSuperset(of: product.dependencies.append(product.name)) }.map(\.name)
                let productModules = modules.filter { module in validProductsNames.contains(module.name) }
                return productModules
            }^
        }
        
        
        return modules(inRepos: repos, excludes: excludes).flatMap { modules in
            modules.count > 0 ? EnvIO.pure(modules)^
                              : EnvIO.raiseError(.modules(repos))^
        }^
    }
    
    private func buildPlaygroundBook(modules: [Module], playgroundPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, Void> {
        PlaygroundBook(name: "nef", path: playgroundPath)
            .build(modules: modules)
            .mapError { e in .playgroundBook(info: e.description) }
    }
}
