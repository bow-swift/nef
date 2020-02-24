//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

import Bow
import BowEffects

public struct Clean {
    public init() {}
    
    public func nefPlayground(_ nefPlayground: NefPlaygroundURL) -> EnvIO<CleanEnvironment, CleanError, Void> {
        EnvIO { (env: CleanEnvironment) in
            binding(
                |<-env.console.print(information: "\t• Clean playground '\(nefPlayground.name)'"),
            yield: ())^.reportStatus(console: env.console)
        }
    }
}
