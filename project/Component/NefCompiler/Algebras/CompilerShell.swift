//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

public protocol CompilerShell {
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void>
    func carthage(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void>
    func build(xcworkspace: URL, scheme: String, platform: Platform, derivedData: URL, log: URL) -> IO<CompilerShellError, Void>
    func dependencies(platform: Platform) -> IO<CompilerShellError, URL>
    func compile(file: URL, sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL], output: URL, log: URL) -> IO<CompilerShellError, Void>
}
