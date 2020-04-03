//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import Bow
import BowEffects

public struct Clean {
    public init() {}
    
    public func nefPlayground(_ nefPlayground: NefPlaygroundURL) -> EnvIO<CleanEnvironment, CleanError, Void> {
        EnvIO { (env: CleanEnvironment) in
            let step = CleanEvent.cleaningPlayground(nefPlayground.name)
            return binding(
                |<-env.progressReport.inProgress(step),
                |<-env.shell.clean(playground: nefPlayground).provide(env.fileSystem).mapError { e in .clean(info: e) },
                yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
}
