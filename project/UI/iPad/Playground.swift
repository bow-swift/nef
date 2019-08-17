//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Swiftline

struct Playground {
    private let resolvePath: ResolvePath
    private let storage = Storage()
    
    init(packagePath: String, projectName: String, outputPath: String) {
        resolvePath = ResolvePath(packagePath: packagePath, projectName: projectName, outputPath: outputPath)
    }
    
    func build() -> PlaygroundError? {
        makeStructure(projectPath: resolvePath.projectPath, buildPath: resolvePath.buildPath)
        guard buildPackage(resolvePath.packagePath, nefPath: resolvePath.nefPath, buildPath: resolvePath.buildPath) else {
            return .package(packagePath: resolvePath.packagePath)
        }
        
        let repos = repositories(checkoutPath: resolvePath.checkoutPath)
        let modules = repos.flatMap { modulesInRepository($0).filter { $0.type == .library && $0.moduleType == .swift } }
        guard modules.count > 0 else { return .checkout }
        
        return nil
    }
    
    // MARK: private methods
    private func makeStructure(projectPath: String, buildPath: String) {
        storage.createFolder(path: projectPath)
        storage.createFolder(path: buildPath)
    }

    private func buildPackage(_ packagePath: String, nefPath: String, buildPath: String) -> Bool {
        guard case .success = storage.copy(packagePath, to: nefPath) else { return false }
        
        let result = run("swift package --package-path \(nefPath)/.. --build-path \(buildPath) resolve")
        return result.exitStatus == 0
    }

    // MARK: private methods <module>
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
    case package(packagePath: String)
    case checkout
    
    var information: String {
        switch self {
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
}
