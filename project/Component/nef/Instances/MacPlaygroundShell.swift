//  Copyright © 2019 The nef Authors.

import Foundation
import NefSwiftPlayground
import BowEffects
import Swiftline

class MacPlaygroundShell: PlaygroundShell {
    
    func itemPaths(in directory: String) -> IO<PlaygroundShellError, [String]> {
        let result = run("ls \(directory)")
        guard result.exitStatus == 0 else { return IO.raiseError(.empty(directory: directory))^ }
        
        let paths = result.stdout.components(separatedBy: "\n").map { "\(directory)/\($0)" }
        return IO.pure(paths)^
    }
    
    func resolve(packagePath: String, buildPath: String) -> IO<PlaygroundShellError, Void> {
        let result = run("swift package --package-path \(packagePath) --build-path \(buildPath) resolve")
        guard result.exitStatus == 0 else { return IO.raiseError(.dependencies(package: packagePath))^ }
        return IO.pure(())^
    }
    
    func describe(repositoryPath: String) -> IO<PlaygroundShellError, Data> {
        let result = run("swift package --package-path \(repositoryPath) describe --type json")
        guard result.exitStatus == 0,
              !result.stdout.isEmpty,
              let data = result.stdout.data(using: .utf8) else { return IO.raiseError(.describe(repository: repositoryPath))^ }
        
        return IO.pure(data)^
    }
    
    func linkPath(itemPath: String, parentPath: String) -> IO<PlaygroundShellError, String> {
        func linkPath(item: String) -> IO<PlaygroundShellError, String> {
            let result = run("readlink file \(item)")
            guard result.exitStatus == 0 else { return IO.raiseError(.linkPath(item: item))^ }
            guard result.stdout.isEmpty else  { return linkPath(item: result.stdout) }
            return IO.pure(item)^
        }
        
        return linkPath(item: itemPath).map { itemPath in
            "\(parentPath)/\(itemPath)".replacingOccurrences(of: "//", with: "/")
        }^
    }
}
