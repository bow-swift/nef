//  Copyright © 2019 The nef Authors.

import CLIKit
import nef
import Bow
import BowEffects

private let console = Console(script: "nef-markdown-page",
                              description: "Render a markdown file from a Playground page",
                              arguments: .init(name: "page", placeholder: "path-to-playground-page", description: "path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`"),
                                         .init(name: "output", placeholder: "path-to-output", description: "path where markdown are saved to. ex. `/home`"),
                                         .init(name: "filename", placeholder: "name", description: "name for the rendered Markdown file (without any extension).", default: "README"),
                                         .init(name: "verbose", placeholder: "", description: "run markdown page in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (content: String, filename: String, output: URL, verbose: Bool)> {
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

        return IO.pure((content: pageContent, filename: pagePath.filename.removeExtension, output: output, verbose: verbose))
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
        Step(total: 3, partial: partial, duration: duration)
    }
    
    let args = IOPartial<CLIKit.Console.Error>.var((content: String, filename: String, output: URL, verbose: Bool).self)
    let output = IOPartial<CLIKit.Console.Error>.var((url: URL, tree: String, trace: String).self)
    
    return binding(
           args <- arguments(console: console),
                |<-console.printStep(step: step(partial: 1), information: "Reading "+"arguments".bold),
                |<-console.printStatus(success: true),
                |<-console.printSubstep(step: step(partial: 1), information: ["filename: \(args.get.filename)", "output: \(args.get.output.path)", "verbose: \(args.get.verbose)"]),
                |<-console.printStep(step: step(partial: 2), information: "Render "+"markdown".bold+" (\(args.get.filename))".lightGreen),
         output <- nef.Markdown.renderVerbose(content: args.get.content, toFile: args.get.output).mapLeft { e in .render(information: "\(e)") }^,
    yield: args.get.verbose ? Either<(tree: String, trace: String), URL>.left((tree: output.get.tree, trace: output.get.trace))
                            : Either<(tree: String, trace: String), URL>.right(output.get.url)
    )^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)") },
               { rendered in
                 rendered.fold({ (tree, trace) in console.exit(success: "rendered markdown page.\n\n• AST \n\t\(tree)\n\n• Trace \n\t\(trace)") },
                               { (page)        in console.exit(success: "rendered markdown page '\(page.path)'")                                })
               })
        .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
