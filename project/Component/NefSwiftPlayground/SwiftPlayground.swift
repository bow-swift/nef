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
           modulesRaw <- self.checkout(content: self.packageContent, resolutionPath: self.resolutionPath),
              modules <- self.modules(packagePath: self.resolutionPath.packagePath, repos: modulesRaw.get, excludes: excludes),
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
    
    private func checkout(content: String, resolutionPath: PlaygroundResolutionPath) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [String]> {
        EnvIO { env in
            let repos = IOPartial<SwiftPlaygroundError>.var([String].self)
            let step = PlaygroundBookEvent.downloadingDependencies
            
            return binding(
                     |<-env.progressReport.inProgress(step),
                     |<-self.buildPackage(content: content,
                                          packageFilePath: resolutionPath.packageFilePath,
                                          packagePath: resolutionPath.packagePath,
                                          buildPath: resolutionPath.buildPath).provide((env.system, env.shell)),
               repos <- self.repositories(checkoutPath: resolutionPath.checkoutPath).provide(env.system),
            yield: repos.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func modules(packagePath: String, repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PlaygroundEnvironment, SwiftPlaygroundError, [Module]> {
        EnvIO { env in
            let modules = IO<SwiftPlaygroundError, [Module]>.var()
            let step = PlaygroundBookEvent.gettingModules
            
            return binding(
                        |<-env.progressReport.inProgress(step),
                modules <- self.swiftLibraryModules(packagePath: packagePath, repos: repos, excludes: excludes).provide(env.shell),
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
        EnvIO.accessM { (system, shell) in
            binding(
                |<-system.write(content: content, toFile: packageFilePath).mapError { e in SwiftPlaygroundError.checkout(info: e.description) }.env(),
                |<-shell.resolve(packagePath: packagePath, buildPath: buildPath).mapError { e in SwiftPlaygroundError.checkout(info: e.description) },
            yield: ())^
        }
    }
    
    private func repositories(checkoutPath: String) -> EnvIO<FileSystem, SwiftPlaygroundError, [String]> {
        EnvIO { fileSystem in
            fileSystem.items(atPath: checkoutPath, recursive: false)
                      .mapError { e in .checkout(info: e.description) }
        }
    }
    
    private func packageGraph(packagePath: String) -> EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]> {
        func flattenDependencies(products: [SwiftPackageProduct]) -> [SwiftPackageProduct] {
            func flattenDependencies(_ dependencies: [String], in products: [SwiftPackageProduct]) -> [String] {
                dependencies.reduce([String]()) { acc, dependency in
                    guard let product = products.first(where: { $0.name == dependency }) else { return acc + [dependency] }
                    return acc + [dependency] + flattenDependencies(product.dependencies, in: products)
                }.uniques()
            }
            
            return products.compactMap { product in
                let dependencies = flattenDependencies(product.dependencies, in: products)
                return SwiftPackageProduct(name: product.name, dependencies: dependencies)
            }
        }
        
        func productsDescription(swiftPackage: SwiftPackage) -> EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]> {
            EnvIO.pure(
                swiftPackage.products
                    .filter { $0.type == .library }
                    .map { library -> SwiftPackageProduct in
                        let dependencies = swiftPackage.targets
                            .filter { target in library.targets.contains(target.name) }
                            .map(\.dependencies)
                            .flatMap { $0.targets + $0.products }
                            .uniques()
                        
                        return .init(name: library.name, dependencies: dependencies)
                    }
            )^
        }
        
        let env =  EnvIO<PackageShell, SwiftPlaygroundError, PackageShell>.var()
        let package = EnvIO<PackageShell, SwiftPlaygroundError, SwiftPackage>.var()
        let products = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
        
        return binding(
                 env <- .ask(),
             package <- env.get.dumpPackage(packagePath: packagePath).mapError(SwiftPlaygroundError.dumpPackage),
            products <- productsDescription(swiftPackage: package.get),
        yield: flattenDependencies(products: products.get))^
    }
    
    private func swiftLibraryModules(packagePath: String, repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
        func modules(inRepos repos: [String], excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            let modulesInPackage = curry(flip(modules(packagePath:excludes:)))(excludes)
            
            let packageProducts = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
            let reposProducts = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
            let reposModules = EnvIO<PackageShell, SwiftPlaygroundError, [Module]>.var()
            let products = EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]>.var()
            let modules = EnvIO<PackageShell, SwiftPlaygroundError, [Module]>.var()
            
            
            return binding(
               packageProducts <- self.packageGraph(packagePath: packagePath),
                 reposProducts <- repos.parFlatTraverse(self.packageGraph(packagePath:))^,
                  reposModules <- repos.parFlatTraverse(modulesInPackage)^,
                      products <- filterReposProducts(reposProducts.get, byPackage: packageProducts.get),
                       modules <- extractPackageModules(reposModules: reposModules.get, inProducts: products.get),
            yield: modules.get)^
        }
        
        func modules(packagePath: String, excludes: [PlaygroundExcludeItem]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            EnvIO.accessM { shell in
                shell.describe(repositoryPath: packagePath)
                     .map { data in modules(in: data, excludes: excludes) }^
                     .flatMap(linkPathForSources)^
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
            EnvIO.accessM { shell in
                modules.traverse { (module: Module) in
                    let sources = EnvIO<PackageShell, PackageShellError, [String]>.var()
                    
                    return binding(
                        sources <- module.sources.map { relativePath in (relativePath, module.path) }.traverse(shell.linkPath)^,
                    yield: Module.sourcesLens.set(module, sources.get))
                }^
            }
        }
        
        func filterReposProducts(_ reposProducts: [SwiftPackageProduct], byPackage packageProducts: [SwiftPackageProduct]) -> EnvIO<PackageShell, SwiftPlaygroundError, [SwiftPackageProduct]> {
            EnvIO.access { _ in
                let packageProductsNames = packageProducts.names()
                let products = reposProducts.filter { repoProduct in packageProductsNames.contains(repoProduct.name) }
                return products.count == 0 ? reposProducts : products
            }^
        }
        
        func extractPackageModules(reposModules: [Module], inProducts products: [SwiftPackageProduct]) -> EnvIO<PackageShell, SwiftPlaygroundError, [Module]> {
            EnvIO.access { _ in
                let reposModulesNames = Set(reposModules.map(\.name))
                let validProducts = products.filter { product in reposModulesNames.isSuperset(of: product.dependencies.append(product.name)) }
                let validProductsNames = validProducts.names()
                
                let modules = reposModules.filter { module in validProductsNames.contains(module.name) }
                return modules
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
