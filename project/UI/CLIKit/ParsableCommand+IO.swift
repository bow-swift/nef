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
        parseIO()
            .flatMap { command in command.runIO() }^
            .mapError(fullMessage)^
    }
    
    static func fullMessage(_ e: Swift.Error) -> Console.Error {
        .arguments(info: fullMessage(for: e))
    }
    
    static func helpError() -> Console.Error {
        fullMessage(CleanExit.helpRequest(self))
    }
    
    // MARK: helpers
    private static func parseIO() -> IO<Swift.Error, ParsableCommand> {
        IO.invoke { try parseAsRoot() }
    }
    
    private func runIO() -> IO<Swift.Error, ParsableCommand> {
        IO.invoke { try self.run() }.map { _ in self }^
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

/// `ConsoleCommand` default run() method will show help by default in Menu with subcommands and ignore in other case (it will be handle in each submodule)
public extension ConsoleCommand {
    func run() throws {
        guard Self.configuration.subcommands.count > 0 else { return }
        throw Self.helpError()
    }
}
