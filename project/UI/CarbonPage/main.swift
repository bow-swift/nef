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
                                         .init(name: "background", placeholder: "", description: "background color in hexadecimal.", default: "'nef' (#8c44ff)"),
                                         .init(name: "theme", placeholder: "", description: "carbon's theme.", default: "'dracula'"),
                                         .init(name: "size", placeholder: "", description: "export file size [1-5].", default: "'2'"),
                                         .init(name: "font", placeholder: "", description: "carbon's font type.", default: "'firaCode'"),
                                         .init(name: "show-lines", placeholder: "", description: "shows/hides lines of code [true | false].", default: "'true'"),
                                         .init(name: "show-watermark", placeholder: "", description: "shows/hides the watermark [true | false].", default: "'true'"),
                                         .init(name: "verbose", placeholder: "", description: "run carbon page in verbose mode [true | false].", default: "'false'"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, output: URL, style: CarbonStyle, verbose: Bool)> {
    console.input().flatMap { args in
        guard let pagePath = args["page"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath else {
                return IO.raiseError(CLIKit.Console.Error.arguments)
        }
        
        let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
        let output = URL(fileURLWithPath: "\(outputPath)/\(PlaygroundUtils.playgroundName(fromPage: page))")
        guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "could not read page content"))
        }
        
        let backgroundColor = CarbonStyle.Color(hex: args["background"] ?? "") ?? CarbonStyle.Color(default: args["background"] ?? "") ?? CarbonStyle.Color.nef
        let theme = CarbonStyle.Theme(rawValue: args["theme"] ?? "") ?? CarbonStyle.Theme.dracula
        let size = CarbonStyle.Size(factor: args["size"] ?? "") ?? CarbonStyle.Size.x2
        let fontType = CarbonStyle.Font(rawValue: args["font"] ?? "") ?? CarbonStyle.Font.firaCode
        let lines = args["show-lines"] == "false" ? false : true
        let watermark = args["show-watermark"] == "false" ? false : true
        let verbose = args["verbose"] == "true" ? true : false
        
        let carbonStyle = CarbonStyle(background: backgroundColor,
                                      theme: theme,
                                      size: size,
                                      fontType: fontType,
                                      lineNumbers: lines,
                                      watermark: watermark)
        
        return IO.pure((content: pageContent, output: output, style: carbonStyle, verbose: verbose))^
    }^
}

func page(downloader: CarbonDownloader, content: String, output: URL, style: CarbonStyle, verbose: Bool) -> IO<CLIKit.Console.Error, URL> {
    IO.async { callback in
        renderCarbon(downloader: downloader,
                     code: content,
                     style: style,
                     outputPath: output.path,
                     verbose: verbose,
                     success: { callback(.right(output)) },
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
                |<-console.printStep(step: step(partial: 1), information: "Reading arguments"),
           args <- arguments(console: console),
                |<-console.printStatus(step: step(partial: 1), success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["style\n\(args.get.style)",
                                                                              "output: \(args.get.output.path)",
                                                                              "verbose: \(args.get.verbose)"]),
                |<-console.printStep(step: step(partial: 2, duration: .seconds(8)), information: "Render carbon image"),
         output <- page(downloader: downloader, content: args.get.content, output: args.get.output, style: args.get.style, verbose: args.get.verbose),
                |<-console.printStatus(step: step(partial: 2), success: true),
    yield: output.get)^
        .foldM({ e   in console.exit(failure: "\(e)")                                  },
               { url in console.exit(success: "rendered carbon page in '\(url.path)'") })
        .unsafeRunSyncEither(on: .global())
}

// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader)
}
