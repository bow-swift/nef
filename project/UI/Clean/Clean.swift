//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct CleanCommand: ConsoleCommand {
    static var commandName: String = "nef-clean"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Clean up nef Playground")

    @ArgumentParser.Option(help: "Path to nef Playground to clean up")
    var project: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
}

@discardableResult
public func clean(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    CleanCommand.commandName = commandName
    
    func arguments(parsableCommand: CleanCommand) -> IO<CLIKit.Console.Error, URL> {
        IO.pure(parsableCommand.projectURL)^
    }
    
    return CLIKit.Console.default.readArguments(CleanCommand.self)
        .flatMap(arguments)
        .flatMap { input in
            nef.Clean.clean(nefPlayground: input)
                .provide(Console.default)^
                .mapError { _ in .render() }
                .foldM({ e in Console.default.exit(failure: "clean up nef Playground '\(input.path)'. \(e)") },
                       { _ in Console.default.exit(success: "'\(input.path)' clean up successfully")         })    }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
