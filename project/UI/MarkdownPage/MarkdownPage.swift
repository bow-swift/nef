//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum MarkdownPageCommand: String {
    case page
    case output
    case verbose
}


@discardableResult
public func markdownPage(script: String) -> Either<CLIKit.Console.Error, Void> {
    
    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, filename: String, output: URL, verbose: Bool)> {
        console.input().flatMap { args in
            guard let pagePath = args[MarkdownPageCommand.page.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let outputPath = args[MarkdownPageCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let verbose = Bool(args[MarkdownPageCommand.verbose.rawValue] ?? "") else {
                    return IO.raiseError(.arguments)
            }
            
            let page = pagePath.contains("Contents.swift") ? pagePath : "\(pagePath)/Contents.swift"
            let filename = page.parentPath.filename.removeExtension
            let output = URL(fileURLWithPath: outputPath).appendingPathComponent(filename)
            
            guard let pageContent = try? String(contentsOfFile: page), !pageContent.isEmpty else {
                return IO.raiseError(CLIKit.Console.Error.render(information: "could not read playground's page content (\(pagePath.filename))"))
            }

            return IO.pure((content: pageContent, filename: filename, output: output, verbose: verbose))
        }^
    }
    
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let console = Console(script: script,
                          description: "Render a markdown file from a Playground page",
                          arguments: .init(name: MarkdownPageCommand.page.rawValue, placeholder: "path-to-playground-page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                     .init(name: MarkdownPageCommand.output.rawValue, placeholder: "path-to-output", description: "path where markdown files are saved to. ex. `/home`"),
                                     .init(name: MarkdownPageCommand.verbose.rawValue, placeholder: "", description: "run markdown page in verbose mode.", isFlag: true, default: "false"))
    
    let args = IOPartial<CLIKit.Console.Error>.var((content: String, filename: String, output: URL, verbose: Bool).self)
    let output = IO<CLIKit.Console.Error, (url: URL, ast: String, rendered: String)>.var()
    
    return binding(
                |<-console.printStep(step: step(partial: 0), information: "Reading "+"arguments".bold),
           args <- arguments(console: console),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 0), information: ["filename: \(args.get.filename)", "output: \(args.get.output.path)", "verbose: \(args.get.verbose)"]),
         output <- nef.Markdown.renderVerbose(content: args.get.content, toFile: args.get.output)
                               .provide(console)
                               .mapError { e in .render() }^,
    yield: args.get.verbose ? Either<(ast: String, trace: String), URL>.left((ast: output.get.ast, trace: output.get.rendered))
                            : Either<(ast: String, trace: String), URL>.right(output.get.url))^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)") },
               { rendered in
                 rendered.fold({ (ast, trace) in console.exit(success: "rendered markdown page.\n\n• AST \n\t\(ast)\n\n• Trace \n\t\(trace)") },
                               { (page)       in console.exit(success: "rendered markdown page '\(page.path)'")                                })
               })
        .unsafeRunSyncEither()
}
