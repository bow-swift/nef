//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Swiftline

let scriptName = "nef-playground-ipad"
let console = iPadConsole()
let file = File()

func main() {
    let result = arguments(keys: "package", "to", "name")
    guard let packagePath = result["package"],
          let outputPath = result["to"],
          let projectName = result["name"] else {
            Console.help.show(output: console)
            exit(-1)
    }
    
    let projectPath = "\(outputPath)/\(projectName)"
    
    makeStructure(output: outputPath, projectName: projectName)
    guard build(packagePath: packagePath, projectPath: projectPath) else {
        Console.error(information: "could not build project 'Package.swift' :: \(packagePath)").show(output: console)
        exit(-1)
    }
    
    let repos = repositories(projectPath: projectPath)
    repos.forEach { repositoryPath in
        let libraries = modules(repositoryPath: repositoryPath).filter { $0.type == .library && $0.moduleType == .swift }
        guard libraries.count > 0 else {
            Console.error(information: "command 'swift package describe' failed").show(output: console)
            exit(-1)
        }
        
        print("------")
    }
    
}

private func makeStructure(output: String, projectName: String) {
    file.createFolder(path: output, name: projectName)
    file.createFolder(path: "\(output)/\(projectName)", name: "nef/build")
}

private func build(packagePath: String, projectPath: String) -> Bool {
    let buildPath = "\(projectPath)/nef/build"
    let outputPath = "\(projectPath)/nef"
    
    guard let _ = file.copy(packagePath, to: outputPath) else { return false }
    
    let result = run("swift package --package-path \(projectPath) --build-path \(buildPath) resolve")
    return result.exitStatus == 0
}

private func repositories(projectPath: String) -> [String] {
    let checkoutPath = "\(projectPath)/nef/build/checkouts"
    let result = run("ls \(checkoutPath)")
    guard result.exitStatus == 0 else { return [] }
    
    let repositoriesPath = result.stdout.components(separatedBy: "\n").map { "\(checkoutPath)/\($0)" }
    return repositoriesPath.filter { !$0.contains("swift-") }
}

private func modules(repositoryPath: String) -> [Module] {
    let result = run("swift package --package-path \(repositoryPath) describe")
    guard result.exitStatus == 0 else { return [] }
    
    return Module.modules(from: result.stdout)
}

// #: - MAIN <launcher>
main()
