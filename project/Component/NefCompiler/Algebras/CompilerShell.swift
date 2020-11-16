//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import Bow
import BowEffects

public protocol CompilerShell {
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void>
    func carthage(project: URL, platform: Platform, cached: Bool) -> EnvIO<FileSystem, CompilerShellError, Void>
    func build(xcworkspace: URL, scheme: String, platform: Platform, derivedData: URL, log: URL) -> IO<CompilerShellError, Void>
    func dependencies(platform: Platform) -> IO<CompilerShellError, URL>
    func libraries(platform: Platform) -> IO<CompilerShellError, URL>
    func compile(file: URL, options: CompilerOptions, output: URL, log: URL) -> IO<CompilerShellError, Void>
}
