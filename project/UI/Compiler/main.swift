//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

private let console = Console(script: "nefc",
                              description: "Compile Xcode Playground",
                              arguments: .init(name: "project", placeholder: "path-to-input", description: "path to the folder containing Xcode Playgrounds to render"),
                                         .init(name: "use-cache", placeholder: "", description: "use cached dependencies if it is possible.", isFlag: true, default: "false"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, cached: Bool)> {
    console.input().flatMap { args in
        guard let inputPath = args["project"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let cached = Bool(args["use-cache"] ?? "") else { return IO.raiseError(.arguments) }
        
        return IO.pure((input: URL(fileURLWithPath: inputPath, isDirectory: true), cached: cached))
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    arguments(console: console)
        .flatMap { (input, cached) in
            nef.Compiler.compile(playgroundsAt: input, cached: cached)
               .provide(console)^
               .mapError { _ in .render() }
               .foldM({ e in console.exit(failure: "rendering Xcode Playgrounds from '\(input.path)'. \(e)") },
                      { _ in console.exit(success: "'\(input.path)' compiled successfully")            })    }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()