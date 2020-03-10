//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import Bow
import BowEffects

public struct CommandLineTool<T: ConsoleCommand> {
    
    @discardableResult
    public static func unsafeRunSync() -> Either<Console.Error, Void> {
        T.parseArguments()
            .flatMap { (command: ParsableCommand) in command.fix() }^
            .flatMap { (command: ConsoleCommand) in command.main() }^
            .reportStatus(in: .default)
            .unsafeRunSyncEither()^
    }
}
