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
    public static var configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Export Carbon code snippets for a given Playground page")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: ArgumentHelp("Path where Carbon snippets are saved to. ex. `/home`", valueName: "carbon output"))
    private var output: ArgumentPath
    
    @ArgumentParser.Option(help: "Background color in hexadecimal")
    private var background: String = "nef"
    
    @ArgumentParser.Option(help: "Carbon theme")
    private var theme: CarbonStyle.Theme = .dracula
    
    @ArgumentParser.Option(help: "export file size")
    private var size: CarbonStyle.Size = .x2
    
    @ArgumentParser.Option(help: "Carbon font type")
    private var font: CarbonStyle.Font = .firaCode
    
    @ArgumentParser.Option(name: .customLong("show-lines"), help: "Shows/hides lines of code")
    private var lines: Bool = true
    
    @ArgumentParser.Option(name: .customLong("show-watermark"), help: "Shows/hides the watermark")
    private var watermark: Bool = true
    
    @ArgumentParser.Flag(help: "Run carbon page in verbose mode")
    private var verbose: Bool = false
    
    
    public func run() throws {
        try run().provide(ConsoleReport())^.unsafeRunSync()
    }
    
    func run<D: ProgressReport & OutcomeReport>() -> EnvIO<D, nef.Error, Void> {
        let style = CarbonStyle(
            background: CarbonStyle.Color(hex: background) ?? CarbonStyle.Color(default: background) ?? CarbonStyle.Color.nef,
            theme: theme,
            size: size,
            fontType: font,
            lineNumbers: lines,
            watermark: watermark)
        
        return nef.Carbon.renderVerbose(page: page.url, style: style, filename: page.path.filename, into: output.url)
            .outcomeScope()
            .reportOutcome(
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
            }, failure: { _ in "rendering carbon images" })
            .finish()
    }
}
