//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum JekyllCommand: String {
    case project
    case output
    case main = "main-page"
}


@discardableResult
public func jekyll() -> Either<CLIKit.Console.Error, Void> {
    let console = Console(script: "nef-jekyll",
                          description: "Render markdown files that can be consumed from Jekyll to generate a microsite",
                          arguments: .init(name: JekyllCommand.project.rawValue, placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                     .init(name: JekyllCommand.output.rawValue, placeholder: "path-to-output", description: "path where the resulting Markdown files will be generated"),
                                     .init(name: JekyllCommand.main.rawValue, placeholder: "path-to-index", description: "path to 'README.md' file to be used as the index page", default: "README.md"))


    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, output: URL, mainPage: URL)> {
        console.input().flatMap { args in
            guard let inputPath = args[JekyllCommand.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let outputPath = args[JekyllCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let mainPagePath = args[JekyllCommand.main.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath else {
                    return IO.raiseError(.arguments)
            }
            
            let input = URL(fileURLWithPath: inputPath, isDirectory: true)
            let output = URL(fileURLWithPath: outputPath, isDirectory: true)
            let mainPage = mainPagePath == "README.md" ? output.appendingPathComponent("README.md") : URL(fileURLWithPath: mainPagePath, isDirectory: false)
            
            return IO.pure((input: input, output: output, mainPage: mainPage))
        }^
    }
    
    return arguments(console: console)
        .flatMap { (input, output, mainPage) in
            nef.Jekyll.render(playgroundsAt: input, mainPage: mainPage, into: output)
                      .provide(console)^
                      .mapError { _ in .render() }
                      .foldM({ _ in console.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'") },
                             { _ in console.exit(success: "rendered Xcode Playgrounds in '\(output.path)'")   }) }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
