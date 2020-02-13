//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import NefCarbon
import Bow
import BowEffects


enum Shell: String {
    case project
    case output
    case background
    case theme
    case size
    case font
    case lines = "show-lines"
    case watermark = "show-watermark"
}

private let console = Console(script: "nef-carbon",
                              description: "Generates Carbon code snippets",
                              arguments: .init(name: Shell.project.rawValue, placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                         .init(name: Shell.output.rawValue, placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"),
                                         .init(name: Shell.background.rawValue, placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                         .init(name: Shell.theme.rawValue, placeholder: "", description: "carbon's theme.", default: "dracula"),
                                         .init(name: Shell.size.rawValue, placeholder: "", description: "export file size [1-5].", default: "2"),
                                         .init(name: Shell.font.rawValue, placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                         .init(name: Shell.lines.rawValue, placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                         .init(name: Shell.watermark.rawValue, placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, output: URL, style: CarbonStyle)> {
    console.input().flatMap { args in
        guard let inputPath = args[Shell.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args[Shell.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
              let backgroundColor = CarbonStyle.Color(hex: args[Shell.background.rawValue] ?? "") ?? CarbonStyle.Color(default: args[Shell.background.rawValue] ?? ""),
              let theme = CarbonStyle.Theme(rawValue: args[Shell.theme.rawValue] ?? ""),
              let size = CarbonStyle.Size(factor: args[Shell.size.rawValue] ?? ""),
              let fontName = args[Shell.font.rawValue]?.replacingOccurrences(of: "-", with: " ").capitalized,
              let fontType = CarbonStyle.Font(rawValue: fontName),
              let lines = Bool(args[Shell.lines.rawValue] ?? ""),
              let watermark = Bool(args[Shell.watermark.rawValue] ?? "") else { return IO.raiseError(.arguments) }
        
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

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    arguments(console: console)
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


// #: - MAIN <launcher - AppKit>
_ = CarbonApplication {
    main()
}
