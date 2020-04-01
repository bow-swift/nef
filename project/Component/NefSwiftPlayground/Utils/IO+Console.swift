//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels

import Bow
import BowEffects

//extension IO where E == SwiftPlaygroundError {
//    func reportStatus(step: Step, in console: Console, verbose: Bool) -> IO<SwiftPlaygroundError, A> {
//        handleErrorWith { error in
//            let print = console.printStatus(information: error.information, success: false) as IO<E, Void>
//            let raise = IO<SwiftPlaygroundError, A>.raiseError(error)
//            return print.followedBy(raise)
//        }.flatMap { (value: A) in
//            let io = console.printStatus(success: true) as IO<E, Void>
//            
//            let substepIO: IO<E, Void>
//            if verbose, let string = (value as? CustomStringConvertible)?.description, !string.isEmpty {
//                let information = string.clean("[", "]", "\"")
//                                        .components(separatedBy: ", ")
//                                        .map { $0.filename }
//                                        .sorted(by: { $0.lowercased() < $1.lowercased() })
//                substepIO = console.printSubstep(step: step, information: information) as IO<E, Void>
//            } else {
//                substepIO = IO<E, Void>.pure(())^
//            }
//            
//            return io.followedBy(substepIO).as(value)^
//        }^
//    }
//}
