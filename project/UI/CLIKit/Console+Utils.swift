//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

public extension IO where E == Console.Error {
    func reportStatus(in console: Console) -> IO<Console.Error, A> {
        handleErrorWith { error in
            switch error {
            case .help:
                return console.help()
            default:
                let print = console.printStatus(success: false) as IO<E, Void>
                let raise = IO<Console.Error, A>.raiseError(error)
                
                return print.followedBy(raise)
            }
        }.flatMap { (value: A) in
            let io = console.printStatus(success: true) as IO<E, Void>
            return io.as(value)^
        }^
    }
}
