//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import NefCarbon
import Bow
import BowEffects

enum CarbonCommand: String {
    case project
    case output
    case background
    case theme
    case size
    case font
    case lines = "show-lines"
    case watermark = "show-watermark"
}


@discardableResult
public func carbon(script: String) -> Either<CLIKit.Console.Error, Void> {

    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, output: URL, style: CarbonStyle)> {
        console.input().flatMap { args in
            guard let inputPath = args[CarbonCommand.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let outputPath = args[CarbonCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let backgroundColor = CarbonStyle.Color(hex: args[CarbonCommand.background.rawValue] ?? "") ?? CarbonStyle.Color(default: args[CarbonCommand.background.rawValue] ?? ""),
                  let theme = CarbonStyle.Theme(rawValue: args[CarbonCommand.theme.rawValue] ?? ""),
                  let size = CarbonStyle.Size(factor: args[CarbonCommand.size.rawValue] ?? ""),
                  let fontName = args[CarbonCommand.font.rawValue]?.replacingOccurrences(of: "-", with: " ").capitalized,
                  let fontType = CarbonStyle.Font(rawValue: fontName),
                  let lines = Bool(args[CarbonCommand.lines.rawValue] ?? ""),
                  let watermark = Bool(args[CarbonCommand.watermark.rawValue] ?? "") else { return IO.raiseError(.arguments) }
            
            let input = URL(fileURLWithPath: inputPath, isDirectory: true)
            let output = URL(fileURLWithPath: outputPath, isDirectory: true)
            let style = CarbonStyle(background: backgroundColor,
                                    theme: theme,
                                    size: size,
                                    fontType: fontType,
                                    lineNumbers: lines,
                                    watermark: watermark)
            
            return IO.pure((input: input, output: output, style: style))
        }^
    }
    
    let console = Console(script: script,
                          description: "Generates Carbon code snippets",
                          arguments: .init(name: CarbonCommand.project.rawValue, placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                     .init(name: CarbonCommand.output.rawValue, placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"),
                                     .init(name: CarbonCommand.background.rawValue, placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                     .init(name: CarbonCommand.theme.rawValue, placeholder: "", description: "carbon's theme.", default: "dracula"),
                                     .init(name: CarbonCommand.size.rawValue, placeholder: "", description: "export file size [1-5].", default: "2"),
                                     .init(name: CarbonCommand.font.rawValue, placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                     .init(name: CarbonCommand.lines.rawValue, placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                     .init(name: CarbonCommand.watermark.rawValue, placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"))
    
    return arguments(console: console)
        .flatMap { (input, output, style) in
            nef.Carbon.render(playgroundsAt: input, style: style, into: output)
                      .provide(console)^
                      .mapError { _ in .render() }
                      .foldM({ _ in console.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                             { _ in console.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")   }) }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
