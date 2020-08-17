//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import NefCommon
import BowEffects

public protocol CompilerSystem {
    func compile(xcworkspace: URL, atNefPlayground: NefPlaygroundURL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, WorkspaceInfo>
    func compile(page: String, filename: String, inPlayground: URL, atNefPlayground: NefPlaygroundURL, workspace: WorkspaceInfo) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void>
}
