//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct CompilerCommand: ConsoleCommand {
    public static var commandName: String = "nefc"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Compile nef Playground")
    public init() {}
    
    @ArgumentParser.Option(help: "Path to nef Playground to compile")
    var project: String
    
    @ArgumentParser.Flag(name: .customLong("use-cache"), help: "Use cached dependencies if it is possible")
    var cached: Bool
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }

    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { (input, cached) in
                nef.Compiler.compile(nefPlayground: input, cached: cached)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "compiling Xcode Playgrounds from '\(input.path)'. \(e)") },
                           { _ in Console.default.exit(success: "'\(input.path)' compiled successfully")                  })
            }^
    }
    
    private func arguments(parsableCommand: CompilerCommand) -> IO<CLIKit.Console.Error, (input: URL, cached: Bool)> {
        IO.pure((input: parsableCommand.projectURL,
                 cached: parsableCommand.cached))^
    }
}
