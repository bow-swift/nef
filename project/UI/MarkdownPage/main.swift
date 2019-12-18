//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import NefCore
import NefMarkdown
import NefModels
import Bow
import BowEffects

private let console = Console(script: "nef-markdown-page",
                              description: "Render a markdown file from a Playground page",
                              arguments: .init(name: "page", placeholder: "playground's page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                         .init(name: "output", placeholder: "output path", description: "path where markdown are saved to. ex. `/home`"),
                                         .init(name: "filename", placeholder: "name", description: "name for the rendered Markdown file (without any extension). ex. `Readme`"),
                                         .init(name: "verbose", placeholder: "", description: "run markdown page in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, output: URL, verbose: Bool)> {
    console.input().flatMap { args in
        guard let pagePath = args["page"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let filename = args["filename"],
              let verbose = Bool(args["verbose"] ?? "") else {
                return IO.raiseError(CLIKit.Console.Error.arguments)
        }
        
        let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
        let output = URL(fileURLWithPath: outputPath).appendingPathComponent("\(filename).md")
        
        guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "could not read page content"))
        }

        return IO.pure((content: pageContent, output: output, verbose: verbose))
    }^
}

func render(content: String, output: URL, verbose: Bool) -> IO<CLIKit.Console.Error, RenderOutput> {
    IO.async { callback in
        renderMarkdown(content: content,
                       to: output.path,
                       success: { output in callback(.right(output)) },
                       failure: { e in callback(.left(.render(information: e))) })
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let args = IOPartial<CLIKit.Console.Error>.var((content: String, output: URL, verbose: Bool).self)
    let output = IOPartial<CLIKit.Console.Error>.var(RenderOutput.self)
    
    return binding(
           args <- arguments(console: console),
                |<-console.printStep(step: step(partial: 1), information: "Reading arguments"),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["output: \(args.get.output.path)", "verbose: \(args.get.verbose)"]),
                |<-console.printStep(step: step(partial: 2), information: "Render markdown page"),
         output <- render(content: args.get.content, output: args.get.output, verbose: args.get.verbose),
    yield: args.get.verbose ? output.get : nil)^
        .reportStatus(in: console)
        .foldM({ e   in console.exit(failure: "\(e)") },
               { rendered in
                    guard let rendered = rendered else { return console.exit(success: "rendered markdown page.") }
                    return console.exit(success: "rendered markdown page.\n\n• AST \n\t\(rendered.tree)\n\n• Trace \n\t\(rendered.output)")
               })
        .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
