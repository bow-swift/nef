//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum CarbonPageCommand: String {
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


@discardableResult
public func carbonPage(script: String) -> Either<CLIKit.Console.Error, Void> {

    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, filename:String, output: URL, style: CarbonStyle, verbose: Bool)> {
        console.input().flatMap { args in
            guard let pagePath = args[CarbonPageCommand.page.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let outputPath = args[CarbonPageCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let backgroundColor = CarbonStyle.Color(hex: args[CarbonPageCommand.background.rawValue] ?? "") ?? CarbonStyle.Color(default: args[CarbonPageCommand.background.rawValue] ?? ""),
                  let theme = CarbonStyle.Theme(rawValue: args[CarbonPageCommand.theme.rawValue] ?? ""),
                  let size = CarbonStyle.Size(factor: args[CarbonPageCommand.size.rawValue] ?? ""),
                  let fontName = args[CarbonPageCommand.font.rawValue]?.replacingOccurrences(of: "-", with: " ").capitalized,
                  let fontType = CarbonStyle.Font(rawValue: fontName),
                  let lines = Bool(args[CarbonPageCommand.lines.rawValue] ?? ""),
                  let watermark = Bool(args[CarbonPageCommand.watermark.rawValue] ?? ""),
                  let verbose = Bool(args[CarbonPageCommand.verbose.rawValue] ?? "")
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
    
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let console = Console(script: script,
                          description: "Export Carbon code snippets for given Xcode Playground page",
                          arguments: .init(name: CarbonPageCommand.page.rawValue, placeholder: "playground's page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                     .init(name: CarbonPageCommand.output.rawValue, placeholder: "carbon output", description: "path where Carbon snippets are saved to. ex. `/home`"),
                                     .init(name: CarbonPageCommand.background.rawValue, placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                     .init(name: CarbonPageCommand.theme.rawValue, placeholder: "", description: "carbon's theme.", default: "dracula"),
                                     .init(name: CarbonPageCommand.size.rawValue, placeholder: "", description: "export file size [1-5].", default: "2"),
                                     .init(name: CarbonPageCommand.font.rawValue, placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                     .init(name: CarbonPageCommand.lines.rawValue, placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                     .init(name: CarbonPageCommand.watermark.rawValue, placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"),
                                     .init(name: CarbonPageCommand.verbose.rawValue, placeholder: "", description: "run carbon page in verbose mode.", isFlag: true, default: "false"))

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
