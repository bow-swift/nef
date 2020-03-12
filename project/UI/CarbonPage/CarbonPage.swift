//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefModels
import Bow
import BowEffects

struct CarbonPageArguments {
    let content: String
    let filename:String
    let output: URL
    let style: CarbonStyle
    let verbose: Bool
}

public struct CarbonPageCommand: ConsoleCommand {
    public static var commandName: String = "nef-carbon-page"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Export Carbon code snippets for given Playground page")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: ArgumentHelp("Path where Carbon snippets are saved to. ex. `/home`", valueName: "carbon output"))
    private var output: ArgumentPath
    
    @ArgumentParser.Option(default: "nef", help: "Background color in hexadecimal")
    private var background: String
    
    @ArgumentParser.Option(default: .dracula, help: "Carbon theme")
    private var theme: CarbonStyle.Theme
    
    @ArgumentParser.Option(default: .x2, help: "export file size [1-5]")
    private var size: CarbonStyle.Size
    
    @ArgumentParser.Option(default: .firaCode, help: "Carbon font type")
    private var font: CarbonStyle.Font
    
    @ArgumentParser.Option(name: .customLong("show-lines"), default: true, help: "Shows/hides lines of code [true | false]")
    private var lines: Bool
    
    @ArgumentParser.Option(name: .customLong("show-watermark"), default: true, help: "Shows/hides the watermark [true | false]")
    private var watermark: Bool
    
    @ArgumentParser.Flag (help: "Run carbon page in verbose mode")
    private var verbose: Bool
    
    private var pageContent: String? { try? String(contentsOfFile: pageURL.path) }
    private var filename: String { PlaygroundUtils.playgroundName(fromPage: pageURL.path) }
    private var pageURL: URL {
        page.path.contains("Contents.swift")
            ? page.url
            : page.url.appendingPathComponent("Contents.swift")
    }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Carbon.renderVerbose(content: args.content, style: args.style, filename: args.filename, into: args.output)
                    .provide(Console.default)
                    .mapError { _ in .render() }
                    .foldM({ e in Console.default.exit(failure: "rendering carbon images. \(e)") },
                           { (ast, url) in Console.default.exit(success: "rendered carbon images '\(url.path)'.\(args.verbose ? "\n\n• AST \n\t\(ast)" : "")") })
            }^
    }
    
    private func arguments(parsableCommand: CarbonPageCommand) -> IO<CLIKit.Console.Error, CarbonPageArguments> {
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "Error: could not read page content"))^
        }
        
        guard let backgroundColor = CarbonStyle.Color(hex: parsableCommand.background) ?? CarbonStyle.Color(default: parsableCommand.background) else {
            return IO.raiseError(.arguments(info: "Error: invalid background color"))^
        }
        
        let style = CarbonStyle(background: backgroundColor,
                                theme: parsableCommand.theme,
                                size: parsableCommand.size,
                                fontType: parsableCommand.font,
                                lineNumbers: parsableCommand.lines,
                                watermark: parsableCommand.watermark)
        
        return IO.pure(.init(content: pageContent,
                        filename: parsableCommand.filename,
                        output: parsableCommand.output.url,
                        style: style,
                        verbose: parsableCommand.verbose))^
    }
}
