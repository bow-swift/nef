//  Copyright © 2019 The nef Authors.

import Foundation
import NefSwiftPlayground
import BowEffects
import Swiftline

final class UnixPackageShell: PackageShell {
    
    func resolve(packagePath: String, buildPath: String) -> IO<PackageShellError, Void> {
        IO.invoke {
            let result = run("swift", args: ["package", "--package-path", "\(packagePath)", "--build-path", "\(buildPath)", "resolve"])
            guard result.exitStatus == 0 else {
                let error = result.stderr.components(separatedBy: "error:").last?
                                  .trimmingEmptyCharacters.clean("\n   ").clean("\n") ?? ""
                throw PackageShellError.dependencies(package: packagePath, information: error.firstCapitalized)
            }
            return ()
        }
    }
    
    func describe(repositoryPath: String) -> IO<PackageShellError, Data> {
        IO.invoke {
            let result = run("swift", args: ["package", "--package-path", "\(repositoryPath)", "describe", "--type", "json"])
            guard result.exitStatus == 0,
                  !result.stdout.isEmpty,
                  let data = result.stdout.data(using: .utf8) else { throw PackageShellError.describe(repository: repositoryPath) }
            
            return data
        }
    }
    
    func linkPath(itemPath: String, parentPath: String) -> IO<PackageShellError, String> {
        func linkPath(item: String) throws -> String {
            let result = run("readlink", args: ["file", "\(item)"])
            guard result.stderr.isEmpty else { throw PackageShellError.linkPath(item: item) }
            guard result.stdout.isEmpty else  { return try linkPath(item: "\(item.parentPath)/\(result.stdout)") }
            return item
        }
        
        return IO.invoke {
            let itemPath = try linkPath(item: "\(parentPath)/\(itemPath)")
            return itemPath.replacingOccurrences(of: "//", with: "/")
        }
    }
}
