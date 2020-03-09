//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct CompilerCommands: ConsoleCommand {
    static var commandName: String = "nefc"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Compile nef Playground")

    @ArgumentParser.Option(help: "Path to nef Playground to compile")
    var project: String
    
    @ArgumentParser.Flag(name: .customLong("use-cache"), help: "Use cached dependencies if it is possible")
    var cached: Bool
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
}

@discardableResult
public func compiler(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    CompilerCommands.commandName = commandName
    
    func arguments(parsableCommand: CompilerCommands) -> IO<CLIKit.Console.Error, (input: URL, cached: Bool)> {
        IO.pure((input: parsableCommand.projectURL,
                 cached: parsableCommand.cached))^
    }
    
    return CLIKit.Console.default.readArguments(CompilerCommands.self)
        .flatMap(arguments)
        .flatMap { (input, cached) in
            nef.Compiler.compile(nefPlayground: input, cached: cached)
                .provide(Console.default)^
                .mapError { _ in .render() }
                .foldM({ e in Console.default.exit(failure: "compiling Xcode Playgrounds from '\(input.path)'. \(e)") },
                       { _ in Console.default.exit(success: "'\(input.path)' compiled successfully")                  }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
