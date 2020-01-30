//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

public protocol CompilerShell {
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void>
    func carthage(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void>
}
