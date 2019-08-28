//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Swiftline

struct Playground {
    private let resolvePath: ResolvePath
    private let storage = Storage()
    private let console: iPadConsole
    
    init(packagePath: String, projectName: String, outputPath: String, console: iPadConsole) {
        self.resolvePath = ResolvePath(packagePath: packagePath, projectName: projectName, outputPath: outputPath)
        self.console = console
    }
    
    func build() -> Result<Void, PlaygroundError> {
        return stepStructure().flatMap(stepChekout).flatMap(stepPlayground)
    }
    
    private func stepStructure() -> Result<Void, PlaygroundError> {
        console.printStep(information: "Creating swift playground structure \(resolvePath.projectName)")
        
        if makeStructure(projectPath: resolvePath.projectPath, buildPath: resolvePath.buildPath) {
            console.printStatus(success: true)
            return .success(())
        } else {
            return .failure(.structure)
        }
    }
    
    private func stepChekout() -> Result<[Module], PlaygroundError> {
        console.printStep(information: "Get the whole modules from dependencies")
        
        let repos = repositories(checkoutPath: resolvePath.checkoutPath)
        let modules = repos.flatMap { modulesInRepository($0).filter { $0.type == .library && $0.moduleType == .swift } }
        
        if modules.count > 0 {
            console.printStatus(success: true)
            modules.forEach { console.printSubstep(information: $0.name) }
            return .success(modules)
        } else {
            return .failure(.checkout)
        }
    }
    
    private func stepPlayground(modules: [Module]) -> Result<Void, PlaygroundError> {
        console.printStep(information: "Building Swift Playground")
        
        buildPlaygroundBook(modules: modules)
        console.printStatus(success: true)
        return .success(())
    }
    
    // MARK: private methods <step helpers>
    private func makeStructure(projectPath: String, buildPath: String) -> Bool {
        storage.createFolder(path: projectPath)
        let result = storage.createFolder(path: buildPath)
        
        if case .success = result {
            return true
        } else if case .failure(.exist) = result {
            return true
        } else {
            return false
        }
    }
    
    private func buildPlaygroundBook(modules: [Module]) {
        storage.remove(filePath: resolvePath.playgroundPath)
        PlaygroundBook(name: "nef", path: resolvePath.playgroundPath, storage: storage).create(withModules: modules)
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
    
    var information: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .package(let path):
            return "could not build project 'Package.swift' :: \(path)"
        case .checkout:
            return "command 'swift package describe' failed"
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
