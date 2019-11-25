//  Copyright © 2019 The nef Authors.

import Foundation

struct ResolvePath {
    let projectName: String
    let outputPath: String
}

extension ResolvePath {
    private var nefFolder: String { "nef" }
    private var buildFolder: String { "\(nefFolder)/build"}
    
    var projectPath: String { "\(outputPath)/\(projectName)" }
    
    var packagePath: String { "\(projectPath)/Package.swift" }
    var packageResolvedPath: String { "\(projectPath)/Package.resolved" }
    
    var nefPath: String { "\(projectPath)/\(nefFolder)"}
    var buildPath: String { "\(projectPath)/\(buildFolder)"}
    var checkoutPath: String { "\(projectPath)/nef/build/checkouts" }
    
    var playgroundPath: String { "\(projectPath)/\(projectName).playgroundbook" }
}
