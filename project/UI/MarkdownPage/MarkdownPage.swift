//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct MarkdownPageArguments {
    let content: String
    let filename: String
    let output: URL
    let verbose: Bool
}

public struct MarkdownPageCommand: ConsoleCommand {
    public static var commandName: String = "nef-markdown-page"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render a markdown file from a Playground page")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where markdown files are saved to. ex. `/home`")
    private var output: ArgumentPath
    
    @ArgumentParser.Flag (help: "Run markdown page in verbose mode.")
    private var verbose: Bool
    
    private var pageContent: String? { try? String(contentsOfFile: pageURL.path) }
    private var pageURL: URL {
        page.path.contains("Contents.swift")
            ? page.url
            : page.url.appendingPathComponent("Contents.swift")
    }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Markdown.renderVerbose(content: args.content, toFile: args.output)
                    .provide(Console.default)
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "rendering markdown page. \(e)") },
                           { (url, ast, rendered) in Console.default.exit(success: "rendered markdown page '\(url.path)'.\(args.verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")") })
                
            }^
    }
    
    private func arguments(parsableCommand: MarkdownPageCommand) -> IO<CLIKit.Console.Error, MarkdownPageArguments> {
        let filename = parsableCommand.page.url.lastPathComponent.removeExtension
        let output = parsableCommand.output.url.appendingPathComponent(filename)
        
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "Error: could not read playground's page content (\(filename))"))^
        }
        
        return IO.pure(.init(content: pageContent,
                             filename: filename,
                             output: output,
                             verbose: parsableCommand.verbose))^
    }
}
