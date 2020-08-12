//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol PackageShell {
    func dumpPackage<D>(packagePath: String) -> EnvIO<D, PackageShellError, SwiftPackage>
    func resolve<D>(packagePath: String, buildPath: String) -> EnvIO<D, PackageShellError, Void>
    func describe<D>(repositoryPath: String) -> EnvIO<D, PackageShellError, Data>
    func linkPath<D>(itemPath: String, parentPath: String) -> EnvIO<D, PackageShellError, String>
}
