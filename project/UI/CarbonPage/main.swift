//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import NefCarbon
import Bow
import BowEffects

enum Shell: String {
    case page
    case output
    case background
    case theme
    case size
    case font
    case lines = "show-lines"
    case watermark = "show-watermark"
    case verbose
}

private let console = Console(script: "nef-carbon-page",
                              description: "Export Carbon code snippets for given Xcode Playground page",
                              arguments: .init(name: Shell.page.rawValue, placeholder: "playground's page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                         .init(name: Shell.output.rawValue, placeholder: "carbon output", description: "path where Carbon snippets are saved to. ex. `/home`"),
                                         .init(name: Shell.background.rawValue, placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                         .init(name: Shell.theme.rawValue, placeholder: "", description: "carbon's theme.", default: "dracula"),
                                         .init(name: Shell.size.rawValue, placeholder: "", description: "export file size [1-5].", default: "2"),
                                         .init(name: Shell.font.rawValue, placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                         .init(name: Shell.lines.rawValue, placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                         .init(name: Shell.watermark.rawValue, placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"),
                                         .init(name: Shell.verbose.rawValue, placeholder: "", description: "run carbon page in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, filename:String, output: URL, style: CarbonStyle, verbose: Bool)> {
    console.input().flatMap { args in
        guard let pagePath = args[Shell.page.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args[Shell.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
              let backgroundColor = CarbonStyle.Color(hex: args[Shell.background.rawValue] ?? "") ?? CarbonStyle.Color(default: args[Shell.background.rawValue] ?? ""),
              let theme = CarbonStyle.Theme(rawValue: args[Shell.theme.rawValue] ?? ""),
              let size = CarbonStyle.Size(factor: args[Shell.size.rawValue] ?? ""),
              let fontName = args[Shell.font.rawValue]?.replacingOccurrences(of: "-", with: " ").capitalized,
              let fontType = CarbonStyle.Font(rawValue: fontName),
              let lines = Bool(args[Shell.lines.rawValue] ?? ""),
              let watermark = Bool(args[Shell.watermark.rawValue] ?? ""),
              let verbose = Bool(args[Shell.verbose.rawValue] ?? "")
            else {
                return IO.raiseError(.arguments)
        }
        
        let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
        let filename = PlaygroundUtils.playgroundName(fromPage: page)
        let output = URL(fileURLWithPath: outputPath)
        
        guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "could not read page content"))
        }
            
        return IO.pure((content: pageContent,
                        filename: filename,
                        output: output,
                        style: CarbonStyle(background: backgroundColor,
                                           theme: theme,
                                           size: size,
                                           fontType: fontType,
                                           lineNumbers: lines,
                                           watermark: watermark),
                        verbose: verbose))^
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }

    let args = IO<CLIKit.Console.Error, (content: String, filename: String, output: URL, style: CarbonStyle, verbose: Bool)>.var()
    let output = IO<CLIKit.Console.Error, (ast: String, url: URL)>.var()

    return binding(
                |<-console.printStep(step: step(partial: 1), information: "Reading "+"arguments".bold),
           args <- arguments(console: console),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["style\n\(args.get.style)",
                                                                              "filename: \(args.get.filename)",
                                                                              "output: \(args.get.output.path)",
                                                                              "verbose: \(args.get.verbose)"]),
         output <- nef.Carbon.renderVerbose(content: args.get.content, style: args.get.style, filename: args.get.filename, into: args.get.output)
                             .provide(console)
                             .mapError { _ in .render() }^,
                |<-console.printStep(step: step(partial: 1), information: "Rendering playground page"),
    yield: args.get.verbose ? Either<(ast: String, url: URL), URL>.left(output.get)
                            : Either<(ast: String, url: URL), URL>.right(output.get.url))^
            .reportStatus(in: console)
            .foldM({ e in console.exit(failure: "\(e)") },
                   { rendered in
                        rendered.fold({ (ast, url) in console.exit(success: "rendered carbon images at '\(url.path)'.\n\n• AST \n\t\(ast)") },
                                      { (url)      in console.exit(success: "rendered carbon images at '\(url.path)'")                      })
                   })
            .unsafeRunSyncEither()
}


// #: - MAIN <launcher - AppKit>
_ = CarbonApplication {
    main()
}
