//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import NefCarbon
import Bow
import BowEffects

private let console = Console(script: "nef-carbon",
                              description: "Generates Carbon code snippets",
                              arguments: .init(name: "project", placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                         .init(name: "output", placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"),
                                         .init(name: "background", placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                         .init(name: "theme", placeholder: "", description: "carbon's theme.", default: "dracula"),
                                         .init(name: "size", placeholder: "", description: "export file size [1-5].", default: "2"),
                                         .init(name: "font", placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                         .init(name: "show-lines", placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                         .init(name: "show-watermark", placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, output: URL, style: CarbonStyle)> {
    console.input().flatMap { args in
        guard let inputPath = args["project"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let backgroundColor = CarbonStyle.Color(hex: args["background"] ?? "") ?? CarbonStyle.Color(default: args["background"] ?? ""),
              let theme = CarbonStyle.Theme(rawValue: args["theme"] ?? ""),
              let size = CarbonStyle.Size(factor: args["size"] ?? ""),
              let fontName = args["font"]?.replacingOccurrences(of: "-", with: " ").capitalized,
              let fontType = CarbonStyle.Font(rawValue: fontName),
              let lines = Bool(args["show-lines"] ?? ""),
              let watermark = Bool(args["show-watermark"] ?? "") else { return IO.raiseError(.arguments) }
        
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
