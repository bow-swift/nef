//  Copyright © 2019 The nef Authors.

import CLIKit
import nef
import Bow
import BowEffects

private let console = Console(script: "nef-markdown",
                              description: "Render markdown files from Xcode Playground",
                              arguments: .init(name: "folder", placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                         .init(name: "output", placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"),
                                         .init(name: "verbose", placeholder: "", description: "run markdown render in verbose mode.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (folder: URL, output: URL, verbose: Bool)> {
    console.input().flatMap { args in
        guard let inputPath = args["folder"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let verbose = Bool(args["verbose"] ?? "") else {
                return IO.raiseError(CLIKit.Console.Error.arguments)
        }
        
        let folder = URL(fileURLWithPath: inputPath, isDirectory: true)
        let output = URL(fileURLWithPath: outputPath, isDirectory: true)

        return IO.pure((folder: folder,
                        output: output,
                        verbose: verbose))
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    arguments(console: console)

//        |<-env.console.printStep(step: step.increment(1), information: "Rendering markdown files for '\(playground.path.filename)'"),
        .flatMap { (folder, output, verbose) in
            nef.Markdown.render(playgroundsAt: folder, in: output)
               .provide(console)^
               .mapLeft { _ in .render() }
               .foldM({ _ in console.exit(failure: "rendering Xcode Playgrounds from '\(folder.path)'") },
                      { _ in console.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")  }) }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}


// #: - MAIN <launcher>
main()
