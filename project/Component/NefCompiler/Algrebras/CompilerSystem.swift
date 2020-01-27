//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol CompilerSystem {
    func compile(page: RenderingOutput<String>) -> IO<CompilerSystemError, Void>
//    func resolve(packagePath: String, buildPath: String) -> IO<PlaygroundShellError, Void>
//    func describe(repositoryPath: String) -> IO<PlaygroundShellError, Data>
//    func linkPath(itemPath: String, parentPath: String) -> IO<PlaygroundShellError, String>
}
