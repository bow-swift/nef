//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct CompilerArguments {
    let input: URL
    let cached: Bool
}

public struct CompilerCommand: ConsoleCommand {
    public static var commandName: String = "nefc"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Compile nef Playground")
    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to compile", valueName: "nef playground"))
    var project: String
    
    @ArgumentParser.Flag(name: .customLong("use-cache"), help: "Use cached dependencies if it is possible")
    var cached: Bool
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }

    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Compiler.compile(nefPlayground: args.input, cached: args.cached)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "compiling Xcode Playgrounds from '\(args.input.path)'. \(e)") },
                           { _ in Console.default.exit(success: "'\(args.input.path)' compiled successfully")                  })
            }^
    }
    
    private func arguments(parsableCommand: CompilerCommand) -> IO<CLIKit.Console.Error, CompilerArguments> {
        IO.pure(.init(input: parsableCommand.projectURL,
                      cached: parsableCommand.cached))^
    }
}
