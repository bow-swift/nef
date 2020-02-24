//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefClean

import Bow
import BowEffects


public extension CleanAPI {
    
    static func clean(nefPlayground: URL) -> EnvIO<Console, nef.Error, Void> {
        NefClean.Clean()
                .nefPlayground(.init(project: nefPlayground))
                .contramap { console in CleanEnvironment(console: console, fileSystem: MacFileSystem(), shell: MacPlaygroundShell()) }
                .mapError { e in nef.Error.compiler(info: "clean: \(e)") }
    }
}
