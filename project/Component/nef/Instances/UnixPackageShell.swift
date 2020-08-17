//  Copyright © 2019 The nef Authors.

import Foundation
import NefSwiftPlayground
import BowEffects
import Swiftline

final class UnixPackageShell: PackageShell {
    func dumpPackage<D>(packagePath: String) -> EnvIO<D, PackageShellError, SwiftPackage> {
        EnvIO.invoke { _ in
            let result = run("swift", args: ["package", "--package-path", "\(packagePath)", "dump-package"])
            guard result.exitStatus == 0,
                  !result.stdout.isEmpty,
                  let json = result.stdout.data(using: .utf8) else {
                let error = result.stderr.components(separatedBy: "error:").last?
                                  .trimmingEmptyCharacters.clean("\n   ").clean("\n") ?? ""
                throw PackageShellError.dumpPackage(package: packagePath, information: error.firstCapitalized)
            }
            
            guard let package = try? JSONDecoder().decode(SwiftPackage.self, from: json) else {
                throw PackageShellError.dumpPackage(package: packagePath, information: "could not decode Package.swift")
            }
            
            return package
        }
    }
    
    func resolve<D>(packagePath: String, buildPath: String) -> EnvIO<D, PackageShellError, Void> {
        EnvIO.invoke { _ in
            let result = run("swift", args: ["package", "--package-path", "\(packagePath)", "--build-path", "\(buildPath)", "resolve"])
            guard result.exitStatus == 0 else {
                let error = result.stderr.components(separatedBy: "error:").last?
                                  .trimmingEmptyCharacters.clean("\n   ").clean("\n") ?? ""
                throw PackageShellError.dependencies(package: packagePath, information: error.firstCapitalized)
            }
            return ()
        }
    }
    
    func describe<D>(repositoryPath: String) -> EnvIO<D, PackageShellError, Data> {
        EnvIO.invoke { _ in
            let result = run("swift", args: ["package", "--package-path", "\(repositoryPath)", "describe", "--type", "json"])
            guard result.exitStatus == 0,
                  !result.stdout.isEmpty,
                  let data = result.stdout.data(using: .utf8) else { throw PackageShellError.describe(repository: repositoryPath) }
            
            return data
        }
    }
    
    func linkPath<D>(itemPath: String, parentPath: String) -> EnvIO<D, PackageShellError, String> {
        func linkPath(item: String) throws -> String {
            let result = run("readlink", args: ["file", "\(item)"])
            guard result.stderr.isEmpty else { throw PackageShellError.linkPath(item: item) }
            guard result.stdout.isEmpty else  { return try linkPath(item: "\(item.parentPath)/\(result.stdout)") }
            return item
        }
        
        return EnvIO.invoke { _ in
            let itemPath = try linkPath(item: "\(parentPath)/\(itemPath)")
            return itemPath.replacingOccurrences(of: "//", with: "/")
        }
    }
}
