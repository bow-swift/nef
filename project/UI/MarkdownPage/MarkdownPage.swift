//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct MarkdownPageCommand: ParsableCommand {
    public static var commandName: String = "nef-markdown-page"
    public static var configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Render a markdown file from a Playground page")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where markdown files are saved to. ex. `/home`")
    private var output: ArgumentPath
    
    @ArgumentParser.Flag(help: "Run markdown page in verbose mode.")
    private var verbose: Bool = false
    
    
    public func run() throws {
        try run().provide(ConsoleReport())^.unsafeRunSync()
    }
    
    func run<D: ProgressReport & OutcomeReport>() -> EnvIO<D, nef.Error, Void> {
        nef.Markdown.renderVerbose(page: page.url, toFile: output.url)
            .outcomeScope()
            .reportOutcome(
                success: { (url, ast, rendered) in
                    if self.verbose {
                        return """
                        rendered Markdown page '\(url.path)'.
                        • AST:
                        \(ast)
                        
                        • Output:
                        \(rendered)
                        """
                    } else {
                        return "rendered Markdown page '\(url.path)'."
                    }
            }, failure: { _ in "rendering Markdown page" })
            .finish()
    }
}
