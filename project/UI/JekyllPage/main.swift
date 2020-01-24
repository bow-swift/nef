//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

private let console = Console(script: "nef-jekyll-page",
                              description: "Render a markdown file from a Playground page that can be consumed from Jekyll",
                              arguments: .init(name: "page", placeholder: "playground's page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                         .init(name: "output", placeholder: "output Jekyll's markdown", description: "path where Jekyll markdown are saved to. ex. `/home`"),
                                         .init(name: "permalink", placeholder: "relative URL", description: "is the relative path where Jekyll will render the documentation. ex. `/about/`"),
                                         .init(name: "verbose", placeholder: "", description: "run jekyll page in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, filename: String, output: URL, permalink: String, verbose: Bool)> {
    console.input().flatMap { args in
        guard let pagePath = args["page"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let permalink = args["permalink"],
              let verbose = Bool(args["verbose"] ?? "") else {
                return IO.raiseError(.arguments)
        }
        
        let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
        let filename = "README.md"
        let output = URL(fileURLWithPath: outputPath).appendingPathComponent(filename)
        
        guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "could not read page content"))
        }
        
        return IO.pure((content: pageContent, filename: filename, output: output, permalink: permalink, verbose: verbose))
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let args = IOPartial<CLIKit.Console.Error>.var((content: String, filename: String, output: URL, permalink: String, verbose: Bool).self)
    let output = IO<CLIKit.Console.Error, (url: URL, ast: String, rendered: String)>.var()
    
    return binding(
                |<-console.printStep(step: step(partial: 1), information: "Reading "+"arguments".bold),
           args <- arguments(console: console),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["filename: \(args.get.filename)", "output: \(args.get.output.path)", "permalink: \(args.get.permalink)", "verbose: \(args.get.verbose)"]),
                |<-console.printStep(step: step(partial: 2), information: "Render "+"Jekyll".bold+" (\(args.get.filename))".lightGreen),
         output <- nef.Jekyll.renderVerbose(content: args.get.content, permalink: args.get.permalink, toFile: args.get.output)
                             .provide(console)
                             .mapLeft { e in .render() }^,
    yield: args.get.verbose ? Either<(ast: String, trace: String), URL>.left((ast: output.get.ast, trace: output.get.rendered))
                            : Either<(ast: String, trace: String), URL>.right(output.get.url))^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)") },
               { rendered in
                 rendered.fold({ (ast, trace) in console.exit(success: "rendered jekyll page.\n\n• AST \n\t\(ast)\n\n• Trace \n\t\(trace)") },
                               { (page)       in console.exit(success: "rendered jekyll page '\(page.path)'")                                })
               })
        .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
