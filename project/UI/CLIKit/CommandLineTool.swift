//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct CommandLineTool<T: ConsoleCommand> {
    
    @discardableResult
    public static func unsafeRunSync() -> Either<Console.Error, Void> {
        T.parseArguments()
            .map { command in command as! ConsoleCommand }^
            .flatMap { command in command.main() }^
            .reportStatus(in: Console.default)
            .unsafeRunSyncEither()^
    }
}
