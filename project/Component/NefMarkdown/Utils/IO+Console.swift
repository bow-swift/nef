//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels

import Bow
import BowEffects

extension IO where E == MarkdownError {
    func reportStatus(step: Step, in console: Console) -> IO<MarkdownError, A> {
        handleErrorWith { error in
            let print = console.printStatus(information: error.information, success: false) as IO<E, Void>
            let raise = IO<MarkdownError, A>.raiseError(error)
            return print.followedBy(raise)
        }.flatMap { (value: A) in
            let io = console.printStatus(success: true) as IO<E, Void>
            return io.as(value)^
        }^
    }
}
