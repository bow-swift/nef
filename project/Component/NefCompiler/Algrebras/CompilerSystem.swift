//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol CompilerSystem {
    func compile(xcworkspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void>
    func compile(page: RenderingOutput<String>) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void>
}
