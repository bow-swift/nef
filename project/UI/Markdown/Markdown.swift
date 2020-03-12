//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct MarkdownArguments {
    let input: URL
    let output: URL
}

public struct MarkdownCommand: ConsoleCommand {
    public static var commandName: String = "nef-markdown"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render Markdown files for given Xcode Playgrounds")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the folder containing Xcode Playground to render")
    var project: String
    
    @ArgumentParser.Option(help: "Path where the resulting Markdown files will be generated")
    var output: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    var outputURL: URL  { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Markdown.render(playgroundsAt: args.input, into: args.output)
                    .provide(Console.default)
                    .mapError { _ in .render() }
                    .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(args.input.path)'") },
                           { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(args.output.path)'")   })
            }^
    }
    
    private func arguments(parsableCommand: MarkdownCommand) -> IO<CLIKit.Console.Error, MarkdownArguments> {
        IO.pure(.init(input: parsableCommand.projectURL,
                      output: parsableCommand.outputURL))^
    }
}
