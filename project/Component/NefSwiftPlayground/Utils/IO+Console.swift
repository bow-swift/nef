//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Bow
import BowEffects


extension IO where E == SwiftPlaygroundError, A == Void {
    func reportStatus(step: Step, in console: Console) -> IO<SwiftPlaygroundError, Void> {
        mapLeft { error in
            _ = console.printStatus(step: step, success: false) as IO<SwiftPlaygroundError, Void>
            return error
        }.map { void in
            _ = console.printStatus(step: step, success: true) as IO<SwiftPlaygroundError, Void>
            return void
        }^
    }
}
