//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

let console = Console(script: "nef-playground-book",
                      description: "Build a Playground Book with 3r-party libraries defined in a Swift Package",
                      arguments: .init(name: "name", placeholder: "swift-playground name", description: "name for the Swift Playground. ex. `nef`"),
                                 .init(name: "package", placeholder: "package path", description: "path to Package.swift file. ex. `/home/Package.swift`"),
                                 .init(name: "output", placeholder: "output path", description: "path where Playground is saved to. ex. `/home`"))


func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (packageContent: String, projectName: String, output: URL)> {
    console.input().flatMap { args in
        guard let projectName = args["name"]?.trimmingEmptyCharacters,
              let packagePath = args["package"]?.trimmingEmptyCharacters.expandingTildeInPath,
              let outputPath  = args["output"]?.trimmingEmptyCharacters.expandingTildeInPath else {
                return IO.raiseError(CLIKit.Console.Error.arguments)
        }
        
        guard let content = try? String(contentsOfFile: packagePath), !content.isEmpty else {
            return IO.raiseError(CLIKit.Console.Error.render(information: "invalid Swift Package"))
        }
        
        return IO.pure((packageContent: content,
                        projectName: projectName,
                        output: URL(fileURLWithPath: outputPath)))^
        
    }^
}

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    arguments(console: console)
        .flatMap { (packageContent, projectName, output) in
            nef.SwiftPlayground.render(packageContent: packageContent, name: projectName, output: output)
                .provide(console)^
                .mapError { _ in .render() }
                .foldM({ _   in console.exit(failure: "rendering Playground Book")                  },
                       { url in console.exit(success: "rendered Playground Book in '\(url.path)'")  }) }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}


// #: - MAIN <launcher>
main()
