//  Copyright © 2020 The nef Authors.

import Foundation
import BowEffects
import ArgumentParser

public protocol ConsoleCommand: ParsableCommand {}
public extension ConsoleCommand {
    func run() throws {}
}


extension ParsableCommand {
    
    static func parseArguments() -> IO<Console.Error, ParsableCommand> {
        parseIO()
            .flatMap { command in command.runIO() }^
            .mapError { e in .arguments(info: fullMessage(for: e)) }
    }
    
    // MARK: helpers
    private static func parseIO() -> IO<Swift.Error, ParsableCommand> {
        IO.invoke { try parseAsRoot() }
    }
    
    private func runIO() -> IO<Swift.Error, ParsableCommand> {
        IO.invoke { try self.run() }.map { _ in self }^
    }
}
