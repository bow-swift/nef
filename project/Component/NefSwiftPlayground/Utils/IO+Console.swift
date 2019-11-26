//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Bow
import BowEffects


extension IO where E == SwiftPlaygroundError {
    func reportStatus(step: Step, in console: Console) -> IO<SwiftPlaygroundError, A> {
        handleErrorWith { error in
            let print = console.printStatus(step: step, information: error.information, success: false) as IO<E, Void>
            let raise = IO<SwiftPlaygroundError, A>.raiseError(error)
            return print.followedBy(raise)
        }.flatMap { (value: A) in
            let io = console.printStatus(step: step, success: true) as IO<E, Void>
            return io.as(value)^
        }^
    }
}
