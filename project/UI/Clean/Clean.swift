//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum CleanCommands: String {
    case project
}


@discardableResult
public func clean(script: String) -> Either<CLIKit.Console.Error, Void> {
    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, URL> {
        console.input().flatMap { args in
            guard let inputPath = args[CleanCommands.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath else {
                return IO.raiseError(.arguments)
            }
            
            let nefPlayground = URL(fileURLWithPath: inputPath, isDirectory: true)
            return IO.pure(nefPlayground)
        }^
    }
    
    let console = Console(script: script,
                          description: "Clean up nef Playground",
                          arguments: .init(name: CleanCommands.project.rawValue, placeholder: "path-nef-playground", description: "path to nef Playground to clean up"))
    
    return arguments(console: console)
        .flatMap { input in
            nef.Clean.clean(nefPlayground: input)
               .provide(console)^
               .mapError { _ in .render() }
               .foldM({ e in console.exit(failure: "clean up nef Playground '\(input.path)'. \(e)") },
                      { _ in console.exit(success: "'\(input.path)' clean up successfully")         })    }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
