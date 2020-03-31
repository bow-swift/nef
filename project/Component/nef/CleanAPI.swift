//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefClean

import Bow
import BowEffects


public extension CleanAPI {
    
    static func clean(nefPlayground: URL) -> EnvIO<ProgressReport, nef.Error, Void> {
        NefClean.Clean()
            .nefPlayground(.init(project: nefPlayground))
            .contramap { progressReport in
                CleanEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    shell: MacNefPlaygroundSystem()) }
            .mapError { e in nef.Error.compiler(info: "clean: \(e)") }
    }
}
