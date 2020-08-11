//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol PackageShell {
    func dumpPackage(packagePath: String) -> IO<PackageShellError, SwiftPackage>
    func resolve(packagePath: String, buildPath: String) -> IO<PackageShellError, Void>
    func describe(repositoryPath: String) -> IO<PackageShellError, Data>
    func linkPath(itemPath: String, parentPath: String) -> IO<PackageShellError, String>
}
