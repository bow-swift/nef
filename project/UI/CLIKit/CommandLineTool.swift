//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import NefCarbon
import Bow
import BowEffects

public struct CommandLineTool<T: ConsoleCommand> {
    
    public static func unsafeRunSync() -> Void {
        _ = CarbonApplication {
            _ = T.parseArguments()
                 .flatMap { (command: ParsableCommand) in command.fix() }^
                 .flatMap { (command: ConsoleCommand) in command.main() }^
                 .reportStatus(in: .default)
                 .unsafeRunSyncEither()^
        }
    }
}
