//  Copyright © 2019 The nef Authors.

import Foundation

struct PlaygroundResolvePath {
    let projectName: String
    let outputPath: String
}

extension PlaygroundResolvePath {
    private var nefFolder: String { "nef" }
    var playgroundPath: String { "\(projectPath)/\(projectName).playgroundbook" }
    var projectPath: String { "\(outputPath)/\(projectName)" }
    
    var packagePath: String { "\(projectPath)/\(nefFolder)" }
    var packageFilePath: String { "\(packagePath)/Package.swift" }
    var packageResolvedPath: String { "\(packagePath)/Package.resolved" }
    
    var buildPath: String { "\(packagePath)/build"}
    var checkoutPath: String { "\(packagePath)/build/checkouts" }
}
