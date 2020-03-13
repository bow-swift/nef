//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct MarkdownPageCommand: ParsableCommand {
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
    
    
    public func run() throws {
        try nef.Markdown.renderVerbose(page: page.url, toFile: output.url)
                .provide(Console.default)
                .foldM({ e in Console.default.exit(failure: "rendering markdown page. \(e)") },
                       { (url, ast, rendered) in Console.default.exit(success: "rendered markdown page '\(url.path)'.\(self.verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")") })^
                .unsafeRunSync()
    }
}
