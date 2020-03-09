//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct MarkdownPageCommand: ConsoleCommand {
    static var commandName: String = "nef-markdown-page"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Render a markdown file from a Playground page")

    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    var page: String
    
    @ArgumentParser.Option(help: "Path where markdown files are saved to. ex. `/home`")
    var output: String
    
    @ArgumentParser.Flag (help: "Run markdown page in verbose mode.")
    var verbose: Bool
    
    var pageContent: String? { try? String(contentsOfFile: pagePath) }
    var outputPath: String { output.trimmingEmptyCharacters.expandingTildeInPath }
    var pagePath: String {
        let path = page.trimmingEmptyCharacters.expandingTildeInPath
        return path.contains("Contents.swift") ? path : "\(path)/Contents.swift"
    }
}

@discardableResult
public func markdownPage(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    MarkdownPageCommand.commandName = commandName
    
    func arguments(parsableCommand: MarkdownPageCommand) -> IO<CLIKit.Console.Error, (content: String, filename: String, output: URL, verbose: Bool)> {
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "could not read playground's page content (\(parsableCommand.pagePath.filename))"))^
        }
        
        let filename = parsableCommand.pagePath.parentPath.filename.removeExtension
        let output = URL(fileURLWithPath: parsableCommand.outputPath).appendingPathComponent(filename)
        
        return IO.pure((content: pageContent,
                        filename: filename,
                        output: output,
                        verbose: parsableCommand.verbose))^
    }
    
    return CLIKit.Console.default.readArguments(MarkdownPageCommand.self)
        .flatMap(arguments)
        .flatMap { (content, filename, output, verbose) in
            nef.Markdown.renderVerbose(content: content, toFile: output)
                .provide(Console.default)
                .mapError { _ in .render() }
                .foldM({ e in Console.default.exit(failure: "rendering markdown page. \(e)") },
                       { (url, ast, rendered) in Console.default.exit(success: "rendered markdown page '\(url.path)'.\(verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")") }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
