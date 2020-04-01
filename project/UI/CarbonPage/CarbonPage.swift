//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefModels
import Bow
import BowEffects

public struct CarbonPageCommand: ParsableCommand {
    public static var commandName: String = "nef-carbon-page"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Export Carbon code snippets for a given Playground page")

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
    
    
    public func run() throws {
        try run().provide(ConsoleProgressReport())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<ProgressReport, nef.Error, Void> {
        let style = CarbonStyle(background: CarbonStyle.Color(hex: background) ?? CarbonStyle.Color(default: background) ?? CarbonStyle.Color.nef,
                                theme: theme,
                                size: size,
                                fontType: font,
                                lineNumbers: lines,
                                watermark: watermark)
        
        return nef.Carbon.renderVerbose(page: page.url, style: style, filename: page.path.filename, into: output.url)
            .reportOutcome(
                failure: "rendering carbon images",
                success: { (ast, url) in
                    if self.verbose {
                        return """
                        "rendered carbon images '\(url.path)'.

                        • AST
                            \(ast)"
                        """
                    } else {
                        return "rendered carbon images '\(url.path)'"
                    }
                })
            .finish()
    }
}
