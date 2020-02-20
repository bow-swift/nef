//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum MarkdownCommand: String {
    case project
    case output
}


@discardableResult
public func markdown() -> Either<CLIKit.Console.Error, Void> {
    let console = Console(script: "nef-markdown",
                          description: "Render markdown files from Xcode Playground",
                          arguments: .init(name: MarkdownCommand.project.rawValue, placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                     .init(name: MarkdownCommand.output.rawValue, placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"))


    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, output: URL)> {
        console.input().flatMap { args in
            guard let inputPath = args[MarkdownCommand.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let outputPath = args[MarkdownCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath else {
                    return IO.raiseError(.arguments)
            }
            
            let folder = URL(fileURLWithPath: inputPath, isDirectory: true)
            let output = URL(fileURLWithPath: outputPath, isDirectory: true)

            return IO.pure((input: folder, output: output))
        }^
    }
    
    return arguments(console: console)
        .flatMap { (input, output) in
            nef.Markdown.render(playgroundsAt: input, into: output)
               .provide(console)^
               .mapError { _ in .render() }
               .foldM({ _ in console.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                      { _ in console.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")  }) }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
