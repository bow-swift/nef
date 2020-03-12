//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct JekyllPageArguments {
    let content: String
    let permalink: String
    let output: URL
    let verbose: Bool
}

public struct JekyllPageCommand: ConsoleCommand {
    public static var commandName: String = "nef-jekyll-page"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render a markdown file from a Playground page that can be consumed from Jekyll")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where Jekyll markdown are saved to. ex. `/home`")
    private var output: ArgumentPath
    
    @ArgumentParser.Option(help: ArgumentHelp("Relative path where Jekyll will render the documentation. ex. `/about/`", valueName: "relative URL"))
    private var permalink: String
    
    @ArgumentParser.Flag (help: "Run jekyll page in verbose mode")
    private var verbose: Bool
    
    private var pageContent: String? { try? String(contentsOfFile: pageURL.path) }
    private var outputFile: URL { output.url.appendingPathComponent("README.md") }
    private var pageURL: URL {
        page.path.contains("Contents.swift")
            ? page.url
            : page.url.appendingPathComponent("Contents.swift")
    }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Jekyll.renderVerbose(content: args.content, permalink: args.permalink, toFile: args.output)
                    .provide(Console.default)
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "rendering jekyll page. \(e)") },
                           { (url, ast, rendered) in Console.default.exit(success: "rendered jekyll page '\(url.path)'.\(args.verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")") })
            }^
    }
    
    private func arguments(parsableCommand: JekyllPageCommand) -> IO<CLIKit.Console.Error, JekyllPageArguments> {
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "Error: could not read page content"))^
        }
        
        return IO.pure(.init(content: pageContent,
                             permalink: parsableCommand.permalink,
                             output: parsableCommand.output.url,
                             verbose: parsableCommand.verbose))^
    }
}
