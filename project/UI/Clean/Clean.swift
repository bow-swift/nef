//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct CleanCommand: ConsoleCommand {
    public static var commandName: String = "nef-clean"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Clean up nef Playground")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to nef Playground to clean up")
    public var project: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { input in
                nef.Clean.clean(nefPlayground: input)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "clean up nef Playground '\(input.path)'. \(e)") },
                           { _ in Console.default.exit(success: "'\(input.path)' clean up successfully")         })
            }^
    }
    
    private func arguments(parsableCommand: CleanCommand) -> IO<CLIKit.Console.Error, URL> {
        IO.pure(parsableCommand.projectURL)^
    }
}
