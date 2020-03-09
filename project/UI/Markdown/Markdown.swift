//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct MarkdownCommand: ConsoleCommand {
    static var commandName: String = "nef-markdown"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Render markdown files from nef Playground")

    @ArgumentParser.Option(help: "Path to the folder containing Xcode Playground to render")
    var project: String
    
    @ArgumentParser.Option(help: "Path where the resulting Markdown files will be generated")
    var output: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    var outputURL: URL  { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
}

@discardableResult
public func markdown(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    MarkdownCommand.commandName = commandName
    
    func arguments(parsableCommand: MarkdownCommand) -> IO<CLIKit.Console.Error, (input: URL, output: URL)> {
        IO.pure((input: parsableCommand.projectURL,
                 output: parsableCommand.outputURL))^
    }
    
    return CLIKit.Console.default.readArguments(MarkdownCommand.self)
        .flatMap(arguments)
        .flatMap { (input, output) in
            nef.Markdown.render(playgroundsAt: input, into: output)
                .provide(Console.default)
                .mapError { _ in .render() }
                .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                       { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")   }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
