//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import Bow
import BowEffects

public protocol ConsoleCommand: ParsableCommand {
    func main() -> IO<CLIKit.Console.Error, Void>
}

extension ParsableCommand {
    
    static func parseArguments() -> IO<Console.Error, ParsableCommand> {
        IO.invoke {
            let command = try parseAsRoot()
            try command.run()
            return command
        }.mapError(fullMessage)^
    }
    
    static func fullMessage(_ e: Swift.Error) -> Console.Error {
        .arguments(info: fullMessage(for: e))
    }
    
    static func helpError() -> Swift.Error {
        CleanExit.helpRequest(self)
    }
}

extension ParsableCommand {
    
    func fix() -> IO<Console.Error, ConsoleCommand> {
        IO.invoke {
            guard let consoleCommand = self as? ConsoleCommand else { throw Self.helpError() }
            return consoleCommand
        }
    }
}

/// `ConsoleCommand` run() method will show help by default in Menu with subcommands and ignore in other case (it will be handle in each submodule)
public extension ConsoleCommand {
    func run() throws {
        guard Self.configuration.subcommands.count > 0 else { return }
        throw Self.helpError()
    }
}
