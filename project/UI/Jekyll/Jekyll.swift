//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct JekyllCommand: ConsoleCommand {
    static var commandName: String = "nef-jekyll"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Render markdown files that can be consumed from Jekyll to generate a microsite")

    @ArgumentParser.Option(help: "Path to the Xcode Playground to render")
    var project: String
    
    @ArgumentParser.Option(help: "Path where the resulting jekyll files will be generated")
    var output: String
    
    @ArgumentParser.Option(name: .customLong("main-page"), default: "README.md", help: "Path to 'README.md' file to be used as the index page")
    var main: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    var outputURL: URL  { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    var mainPath: String { main.trimmingEmptyCharacters.expandingTildeInPath }
}

@discardableResult
public func jekyll(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    JekyllCommand.commandName = commandName
    
    func arguments(parsableCommand: JekyllCommand) -> IO<CLIKit.Console.Error, (input: URL, output: URL, mainPage: URL)> {
        let mainURL = parsableCommand.mainPath == "README.md"
            ? parsableCommand.outputURL.appendingPathComponent("README.md")
            : URL(fileURLWithPath: parsableCommand.mainPath, isDirectory: false)
        
        return IO.pure((input: parsableCommand.projectURL,
                        output: parsableCommand.outputURL,
                        mainPage: mainURL))^
    }
    
    return CLIKit.Console.default.readArguments(JekyllCommand.self)
        .flatMap(arguments)
        .flatMap { (input, output, mainPage) in
            nef.Jekyll.render(playgroundsAt: input, mainPage: mainPage, into: output)
                .provide(Console.default)^
                .mapError { _ in .render() }
                .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                       { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")   }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
