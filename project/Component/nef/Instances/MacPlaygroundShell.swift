//  Copyright © 2019 The nef Authors.

import Foundation
import NefSwiftPlayground
import BowEffects
import Swiftline

class MacPlaygroundShell: PlaygroundShell {
    
    func itemPaths(in directory: String) -> IO<PlaygroundShellError, [String]> {
        IO.invoke {
            let result = run("ls \(directory)")
            guard result.exitStatus == 0 else { throw PlaygroundShellError.empty(directory: directory) }
            
            return result.stdout.components(separatedBy: "\n").map { "\(directory)/\($0)" }
        }
    }
    
    func resolve(packagePath: String, buildPath: String) -> IO<PlaygroundShellError, Void> {
        IO.invoke {
            let result = run("swift package --package-path \(packagePath) --build-path \(buildPath) resolve")
            guard result.exitStatus == 0 else { throw PlaygroundShellError.dependencies(package: packagePath) }
        }
    }
    
    func describe(repositoryPath: String) -> IO<PlaygroundShellError, Data> {
        IO.invoke {
            let result = run("swift package --package-path \(repositoryPath) describe --type json")
            guard result.exitStatus == 0,
                  !result.stdout.isEmpty,
                  let data = result.stdout.data(using: .utf8) else { throw PlaygroundShellError.describe(repository: repositoryPath) }
            
            return data
        }
    }
    
    func linkPath(itemPath: String, parentPath: String) -> IO<PlaygroundShellError, String> {
        func linkPath(item: String) throws -> String {
            let result = run("readlink file \(item)")
            guard result.stderr.isEmpty else { throw PlaygroundShellError.linkPath(item: item) }
            guard result.stdout.isEmpty else  { return try linkPath(item: "\(item.parentPath)/\(result.stdout)") }
            return item
        }
        
        return IO.invoke {
            let itemPath = try linkPath(item: "\(parentPath)/\(itemPath)")
            return itemPath.replacingOccurrences(of: "//", with: "/")
        }
    }
}
