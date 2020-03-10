//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct JekyllCommand: ConsoleCommand {
    public static var commandName: String = "nef-jekyll"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render Markdown files that can be consumed from Jekyll to generate a microsite")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the Xcode Playground to render")
    var project: String
    
    @ArgumentParser.Option(help: "Path where the resulting jekyll files will be generated")
    var output: String
    
    @ArgumentParser.Option(name: .customLong("main-page"), default: "README.md", help: "Path to 'README.md' file to be used as the index page")
    var mainPage: String
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    var outputURL: URL  { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    var mainPath: String { mainPage.trimmingEmptyCharacters.expandingTildeInPath }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { (input, output, mainPage) in
                nef.Jekyll.render(playgroundsAt: input, mainPage: mainPage, into: output)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                           { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")   })
            }^
    }
    
    private func arguments(parsableCommand: JekyllCommand) -> IO<CLIKit.Console.Error, (input: URL, output: URL, mainPage: URL)> {
        let mainURL = parsableCommand.mainPath == "README.md"
            ? parsableCommand.outputURL.appendingPathComponent("README.md")
            : URL(fileURLWithPath: parsableCommand.mainPath, isDirectory: false)
        
        return IO.pure((input: parsableCommand.projectURL,
                        output: parsableCommand.outputURL,
                        mainPage: mainURL))^
    }
}
