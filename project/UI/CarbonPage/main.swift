//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit

import NefCommon
import NefModels
import NefCore
import NefCarbon

import Bow
import BowEffects

private let console = Console(script: "nef-carbon-page",
                              description: "Export Carbon code snippets for given Xcode Playground page",
                              arguments: .init(name: "page", placeholder: "playground's page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                         .init(name: "output", placeholder: "carbon output", description: "path where Carbon snippets are saved to. ex. `/home`"),
                                         .init(name: "background", placeholder: "", description: "background color in hexadecimal.", default: "nef"),
                                         .init(name: "theme", placeholder: "", description: "carbon's theme.", default: "dracula"),
                                         .init(name: "size", placeholder: "", description: "export file size [1-5].", default: "2"),
                                         .init(name: "font", placeholder: "", description: "carbon's font type.", default: "fira-code"),
                                         .init(name: "show-lines", placeholder: "", description: "shows/hides lines of code [true | false].", default: "true"),
                                         .init(name: "show-watermark", placeholder: "", description: "shows/hides the watermark [true | false].", default: "true"),
                                         .init(name: "verbose", placeholder: "", description: "run carbon page in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, output: URL, style: CarbonStyle, verbose: Bool)> {
    console.input().flatMap { args in
        guard let pagePath = args["page"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let backgroundColor = CarbonStyle.Color(hex: args["background"] ?? "") ?? CarbonStyle.Color(default: args["background"] ?? ""),
              let theme = CarbonStyle.Theme(rawValue: args["theme"] ?? ""),
              let size = CarbonStyle.Size(factor: args["size"] ?? ""),
              let fontName = args["font"]?.replacingOccurrences(of: "-", with: " ").capitalized,
              let fontType = CarbonStyle.Font(rawValue: fontName),
              let lines = Bool(args["show-lines"] ?? ""),
              let watermark = Bool(args["show-watermark"] ?? ""),
              let verbose = Bool(args["verbose"] ?? "")
            else {
                return IO.raiseError(CLIKit.Console.Error.arguments)
        }
        
        let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
        let output = URL(fileURLWithPath: outputPath).appendingPathComponent(PlaygroundUtils.playgroundName(fromPage: page))
        
        guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "could not read page content"))
        }
            
        return IO.pure((content: pageContent,
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

func render(downloader: CarbonDownloader, content: String, output: URL, style: CarbonStyle, verbose: Bool) -> IO<CLIKit.Console.Error, URL> {
    IO.async { callback in
        renderCarbon(downloader: downloader,
                     code: content,
                     style: style,
                     outputPath: output.path,
                     verbose: verbose,
                     success: { callback(.right(output.deletingLastPathComponent())) },
                     failure: { e in callback(.left(.render(information: e))) })
    }^
}

@discardableResult
func main(_ downloader: CarbonDownloader) -> Either<CLIKit.Console.Error, Void> {
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let args = IOPartial<CLIKit.Console.Error>.var((content: String, output: URL, style: CarbonStyle, verbose: Bool).self)
    let output = IOPartial<CLIKit.Console.Error>.var(URL.self)
    
    return binding(
           args <- arguments(console: console),
                |<-console.printStep(step: step(partial: 1), information: "Reading arguments"),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["style\n\(args.get.style)",
                                                                              "output: \(args.get.output.path)",
                                                                              "verbose: \(args.get.verbose)"]),
                |<-console.printStep(step: step(partial: 2, duration: .seconds(8)), information: "Render carbon image"),
         output <- render(downloader: downloader, content: args.get.content, output: args.get.output, style: args.get.style, verbose: args.get.verbose),
    yield: output.get)^
        .reportStatus(in: console)
        .foldM({ e   in console.exit(failure: "\(e)")                                  },
               { url in console.exit(success: "rendered carbon images in '\(url.path)'") })
        .unsafeRunSyncEither(on: .global())
}


// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader)
}
