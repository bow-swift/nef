//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefModels
import Bow
import BowEffects

struct CarbonPageCommand: ConsoleCommand {
    static var commandName: String = "nef-carbon-page"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Export Carbon code snippets for given Playground page")

    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    var page: String
    
    @ArgumentParser.Option(help: ArgumentHelp("Path where Carbon snippets are saved to. ex. `/home`", valueName: "carbon output"))
    var output: String
    
    @ArgumentParser.Option(default: "nef", help: "Background color in hexadecimal")
    var background: String
    
    @ArgumentParser.Option(default: .dracula, help: "Carbon theme")
    var theme: CarbonStyle.Theme
    
    @ArgumentParser.Option(default: .x2, help: "export file size [1-5]")
    var size: CarbonStyle.Size
    
    @ArgumentParser.Option(default: .firaCode, help: "Carbon font type")
    var font: CarbonStyle.Font
    
    @ArgumentParser.Option(default: true, help: ArgumentHelp("Shows/hides lines of code [true | false]", valueName: "show-lines"))
    var lines: Bool
    
    @ArgumentParser.Option(default: true, help: ArgumentHelp("Shows/hides the watermark [true | false]", valueName: "show-watermark"))
    var watermark: Bool
    
    @ArgumentParser.Flag (help: "Run Carbon page in verbose mode")
    var verbose: Bool
    
    var pageContent: String? { try? String(contentsOfFile: pagePath) }
    var outputURL: URL { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    var filename: String { PlaygroundUtils.playgroundName(fromPage: pagePath) }
    var pagePath: String {
        let path = page.trimmingEmptyCharacters.expandingTildeInPath
        return path.contains("Contents.swift") ? path : "\(path)/Contents.swift"
    }
}

@discardableResult
public func carbonPage(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    CarbonPageCommand.commandName = commandName
    
    func arguments(parsableCommand: CarbonPageCommand) -> IO<CLIKit.Console.Error, (content: String, filename:String, output: URL, style: CarbonStyle, verbose: Bool)> {
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "could not read page content"))^
        }
        
        guard let backgroundColor = CarbonStyle.Color(hex: parsableCommand.background) ?? CarbonStyle.Color(default: parsableCommand.background) else {
            return IO.raiseError(.arguments(info: "invalid background color"))^
        }
        
        return IO.pure((content: pageContent,
                        filename: parsableCommand.filename,
                        output: parsableCommand.outputURL,
                        style: CarbonStyle(background: backgroundColor,
                                           theme: parsableCommand.theme,
                                           size: parsableCommand.size,
                                           fontType: parsableCommand.font,
                                           lineNumbers: parsableCommand.lines,
                                           watermark: parsableCommand.watermark),
                        verbose: parsableCommand.verbose))^
    }
    
    return CLIKit.Console.default.readArguments(CarbonPageCommand.self)
        .flatMap(arguments)
        .flatMap { (content, filename, output, style, verbose) in
            nef.Carbon.renderVerbose(content: content, style: style, filename: filename, into: output)
                .provide(Console.default)
                .mapError { _ in .render() }
                .foldM({ e in Console.default.exit(failure: "rendering carbon images. \(e)") },
                       { (ast, url) in Console.default.exit(success: "rendered carbon images at '\(url.path)'.\(verbose ? "\n\n• AST \n\t\(ast)" : "")") }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
