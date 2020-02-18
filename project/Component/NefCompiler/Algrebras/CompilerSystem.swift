//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import NefCommon
import BowEffects

public protocol CompilerSystem {
    func compile(xcworkspace: URL, atNefPlayground: NefPlaygroundURL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, URL>
    func compile(page: String, filename: String, inPlayground: URL, atNefPlayground: NefPlaygroundURL, platform: Platform, frameworks: [URL]) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void>
}
