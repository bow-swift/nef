//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels

import Bow
import BowEffects

extension IO where E == RenderError {
    
    public func reportStatus(console: Console) -> IO<E, A> {
        handleErrorWith { error in
            let print = console.printStatus(information: error.information, success: false) as IO<E, Void>
            let raise = IO<E, A>.raiseError(error)
            return print.followedBy(raise)
        }.flatMap { (value: A) in
            let io = console.printStatus(success: true) as IO<E, Void>
            return io.as(value)^
        }^
    }
}
