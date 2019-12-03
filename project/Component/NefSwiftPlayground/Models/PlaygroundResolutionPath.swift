//  Copyright © 2019 The nef Authors.

import Foundation

private enum Constants {
    static let nefFolder = "nef"
}

struct PlaygroundResolutionPath {
    let projectName: String
    let outputPath: String
    
    private let projectPath: String
    let playgroundPath: String
    let packagePath: String
    let packageFilePath: String
    let packageResolvedPath: String
    let buildPath: String
    let checkoutPath: String
    
    init(projectName: String, outputPath: String) {
        self.projectName = projectName
        self.outputPath = outputPath
        
        projectPath = "\(outputPath)/\(projectName)"
        playgroundPath = "\(projectPath)/\(projectName).playgroundbook"
        packagePath = "\(projectPath)/\(Constants.nefFolder)"
        packageFilePath = "\(packagePath)/Package.swift"
        packageResolvedPath = "\(packagePath)/Package.resolved"
        buildPath = "\(packagePath)/build"
        checkoutPath = "\(packagePath)/build/checkouts"
    }
}
