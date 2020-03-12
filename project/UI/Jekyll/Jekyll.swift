//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct JekyllArguments {
    let input: URL
    let output: URL
    let mainPage: URL
}

public struct JekyllCommand: ConsoleCommand {
    public static var commandName: String = "nef-jekyll"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render Markdown files that can be consumed from Jekyll to generate a microsite")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the Xcode Playground to render")
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting jekyll files will be generated")
    private var output: ArgumentPath
    
    @ArgumentParser.Option(name: .customLong("main-page"), default: "README.md", help: "Path to 'README.md' file to be used as the index page")
    private var mainPage: String
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Jekyll.render(playgroundsAt: args.input, mainPage: args.mainPage, into: args.output)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(args.input.path)'") },
                           { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(args.output.path)'")   })
            }^
    }
    
    private func arguments(parsableCommand: JekyllCommand) -> IO<CLIKit.Console.Error, JekyllArguments> {
        let mainURL = parsableCommand.mainPage == "README.md"
            ? parsableCommand.output.url.appendingPathComponent("README.md")
            : URL(fileURLWithPath: mainPage.trimmingEmptyCharacters.expandingTildeInPath)
        
        return IO.pure(.init(input: parsableCommand.project.url,
                             output: parsableCommand.output.url,
                             mainPage: mainURL))^
    }
}
