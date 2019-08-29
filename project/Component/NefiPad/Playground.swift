//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Swiftline

struct Playground {
    private let resolvePath: ResolvePath
    private let storage = Storage()
    private let console: ConsoleOutput
    
    init(packagePath: String, projectName: String, outputPath: String, console: ConsoleOutput) {
        self.resolvePath = ResolvePath(packagePath: packagePath, projectName: projectName, outputPath: outputPath)
        self.console = console
    }
    
    func build(cached: Bool) -> Result<Void, PlaygroundError> {
        return stepCleanUp(deintegrate: !cached)
            .flatMap(stepStructure)
            .flatMap(stepChekout)
            .flatMap(stepGetModules)
            .flatMap(stepPlayground)
            .flatMap { _ in stepCleanUp(deintegrate: false) }
    }
    
    private func stepStructure() -> Result<Void, PlaygroundError> {
        console.printLog(step: "Creating swift playground structure (\(resolvePath.projectName))")
        
        if makeStructure(projectPath: resolvePath.projectPath, buildPath: resolvePath.buildPath) {
            console.printLog(status: true)
            return .success(())
        } else {
            console.printLog(status: false)
            return .failure(.structure)
        }
    }
    
    private func stepChekout() -> Result<[String], PlaygroundError> {
        console.printLog(step: "Downloading dependencies...")
        
        guard buildPackage(resolvePath.packagePath, nefPath: resolvePath.nefPath, buildPath: resolvePath.buildPath) else {
            console.printLog(status: false)
            return .failure(.package(packagePath: resolvePath.packagePath))
        }
        
        let repos = repositories(checkoutPath: resolvePath.checkoutPath)
        if repos.count > 0 {
            console.printLog(status: true)
            return .success(repos)
        } else {
            console.printLog(status: false)
            return .failure(.checkout)
        }
    }
    
    private func stepGetModules(fromRepositories repos: [String]) -> Result<[Module], PlaygroundError> {
        console.printLog(step: "Get modules from repositories")
        
        let modules = repos.flatMap {
            modulesInRepository($0).filter { $0.type == .library && $0.language == .swift }
        }
        
        if modules.count > 0 {
            console.printLog(status: true)
            modules.forEach { console.printLog(substep: $0.name) }
            return .success(modules)
        } else {
            console.printLog(status: false)
            return .failure(.checkout)
        }
    }
    
    private func stepPlayground(modules: [Module]) -> Result<Void, PlaygroundError> {
        console.printLog(step: "Building Swift Playground...")
        
        let result = makePlaygroundBook(modules: modules)
        let createdPaygroundBook = (try? result.get()) != nil
        
        console.printLog(status: createdPaygroundBook)
        return result
    }
    
    private func stepCleanUp(deintegrate: Bool) -> Result<Void, PlaygroundError> {
        console.printLog(step: "Clean up files for building")
        
        removePackageResolved()
        if (deintegrate) { cleanBuildFolder() }
        
        console.printLog(status: true)
        return .success(())
    }
    
    // MARK: private methods <step helpers>
    private func makeStructure(projectPath: String, buildPath: String) -> Bool {
        storage.createFolder(path: projectPath)
        let result = storage.createFolder(path: buildPath)
        
        switch result {
        case .success: return true
        case .failure(.exist): return true
        default: return false
        }
    }
    
    private func makePlaygroundBook(modules: [Module]) -> Result<Void, PlaygroundError> {
        storage.remove(filePath: resolvePath.playgroundPath)
        return PlaygroundBook(name: "nef", path: resolvePath.playgroundPath, storage: storage)
                .create(withModules: modules)
                .flatMapError { _ in .failure(.playgroundBook) }
    }
    
    private func removePackageResolved() {
        let packageResolvedPath = "\(resolvePath.packagePath.parentPath)/Package.resolved"
        storage.remove(filePath: packageResolvedPath)
    }
    
    private func cleanBuildFolder() {
        storage.remove(filePath: resolvePath.nefPath)
    }
    
    // MARK: private methods <swift-package-manager>
    private func buildPackage(_ packagePath: String, nefPath: String, buildPath: String) -> Bool {
        guard case .success = storage.copy(packagePath, to: nefPath) else { return false }
        
        let result = run("swift package --package-path \(nefPath)/.. --build-path \(buildPath) resolve")
        return result.exitStatus == 0
    }
    
    private func repositories(checkoutPath: String) -> [String] {
        let result = run("ls \(checkoutPath)")
        guard result.exitStatus == 0 else { return [] }
        
        let repositoriesPath = result.stdout.components(separatedBy: "\n").map { "\(checkoutPath)/\($0)" }
        return repositoriesPath.filter { !$0.contains("swift-") }
    }

    private func modulesInRepository(_ repositoryPath: String) -> [Module] {
        let result = run("swift package --package-path \(repositoryPath) describe")
        guard result.exitStatus == 0 else { return [] }
        
        return Module.modules(from: result.stdout)
    }
}

enum PlaygroundError: Error {
    case structure
    case package(packagePath: String)
    case checkout
    case playgroundBook
    
    var information: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .package(let path):
            return "could not build project 'Package.swift' :: \(path)"
        case .checkout:
            return "command 'swift package describe' failed"
        case .playgroundBook:
            return "could not create Swift Playground"
        }
    }
}

fileprivate struct ResolvePath {
    let packagePath: String
    let projectName: String
    let outputPath: String
    
    private var nefFolder: String { "nef" }
    private var buildFolder: String { "\(nefFolder)/build"}
    
    var projectPath: String { "\(outputPath)/\(projectName)" }
    var nefPath: String { "\(projectPath)/\(nefFolder)"}
    var buildPath: String { "\(projectPath)/\(buildFolder)"}
    var checkoutPath: String { "\(projectPath)/nef/build/checkouts" }
    
    var playgroundPath: String { "\(projectPath)/\(projectName).playgroundbook" }
}
