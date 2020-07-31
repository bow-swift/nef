//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefCarbon
import Bow
import BowEffects

public struct CarbonCommand: ParsableCommand {
    public static var commandName: String = "nef-carbon"
    public static var configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Export Carbon code snippets for a given nef Playground")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to render", valueName: "nef playground"))
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting carbon files will be generated")
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
        
        return nef.Carbon.render(playgroundsAt: project.url, style: style, into: output.url)
            .outcomeScope()
            .reportOutcome(
                success: { _ in
                    "rendered Xcode Playgrounds in '\(self.output.path)'"
                },
                failure: { _ in
                    "rendering Xcode Playgrounds from '\(self.project.path)'"
                })
            .finish()
    }
}
