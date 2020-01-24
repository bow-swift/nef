//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

struct MacDummyConsole: Console {
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void>{
        IO.pure(())^
    }
    
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.pure(())^
    }
    
    func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void> {
        IO.pure(())^
    }
    
    func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void>  {
        IO.pure(())^
    }
}
