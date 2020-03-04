//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

public extension IO where E == Console.Error {
    func reportStatus(in console: Console.Type) -> IO<Console.Error, A> {
        handleErrorWith { error in
            switch error {
            case .arguments(let info):
                return console.help(info)
                
            case .render(let info):
                let print = console.default.print(information: info) as IO<E, Void>
                let raise = IO<Console.Error, A>.raiseError(error)
                return print.followedBy(raise)
            }
        }.flatMap { (value: A) in
            let io = console.default.printStatus(success: true) as IO<E, Void>
            return io.as(value)^
        }^
    }
}
