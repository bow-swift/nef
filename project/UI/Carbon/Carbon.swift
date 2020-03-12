//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefCarbon
import Bow
import BowEffects

struct CarbonArguments {
    let input: URL
    let output: URL
    let style: CarbonStyle
}

public struct CarbonCommand: ConsoleCommand {
    public static var commandName: String = "nef-carbon"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Export Carbon code snippets for given nef Playground")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the nef Playground to render")
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting carbon files will be generated")
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
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.Carbon.render(playgroundsAt: args.input, style: args.style, into: args.output)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(args.input.path)'") },
                           { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(args.output.path)'")   })
            }^
    }
    
    private func arguments(parsableCommand: CarbonCommand) -> IO<CLIKit.Console.Error, CarbonArguments> {
        guard let backgroundColor = CarbonStyle.Color(hex: parsableCommand.background) ?? CarbonStyle.Color(default: parsableCommand.background) else {
            return IO.raiseError(.arguments(info: "Error: invalid background color"))^
        }
        
        let style = CarbonStyle(background: backgroundColor,
                                theme: parsableCommand.theme,
                                size: parsableCommand.size,
                                fontType: parsableCommand.font,
                                lineNumbers: parsableCommand.lines,
                                watermark: parsableCommand.watermark)
        
        return IO.pure(.init(input: parsableCommand.project.url,
                             output: parsableCommand.output.url,
                             style: style))^
    }
}
