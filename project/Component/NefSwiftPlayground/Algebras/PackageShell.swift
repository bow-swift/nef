//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol PackageShell {
    func resolve(packagePath: String, buildPath: String) -> IO<PlaygroundShellError, Void>
    func describe(repositoryPath: String) -> IO<PlaygroundShellError, Data>
    func linkPath(itemPath: String, parentPath: String) -> IO<PlaygroundShellError, String>
}
