//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum CompilerCommands: String {
    case project
    case cached = "use-cache"
}


@discardableResult
public func compiler(script: String) -> Either<CLIKit.Console.Error, Void> {
    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (input: URL, cached: Bool)> {
        console.input().flatMap { args in
            guard let inputPath = args[CompilerCommands.project.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let cached = Bool(args[CompilerCommands.cached.rawValue] ?? "") else { return IO.raiseError(.arguments) }
            
            return IO.pure((input: URL(fileURLWithPath: inputPath, isDirectory: true), cached: cached))
        }^
    }
    
    let console = Console(script: script,
                          description: "Compile nef Playground",
                          arguments: .init(name: CompilerCommands.project.rawValue, placeholder: "path-nef-playground", description: "path to nef Playground to compile"),
                                     .init(name: CompilerCommands.cached.rawValue, placeholder: "", description: "use cached dependencies if it is possible.", isFlag: true, default: "false"))
    
    return arguments(console: console)
        .flatMap { (input, cached) in
            nef.Compiler.compile(nefPlayground: input, cached: cached)
               .provide(console)^
               .mapError { _ in .render() }
               .foldM({ e in console.exit(failure: "compiling Xcode Playgrounds from '\(input.path)'. \(e)") },
                      { _ in console.exit(success: "'\(input.path)' compiled successfully")            })    }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
