//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import BowEffects

public protocol CompilerSystem {
    func compile(xcworkspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL>
    func compile(page: String, inPlayground: URL, platform: Platform, frameworks: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void>
}
