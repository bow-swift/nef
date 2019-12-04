//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import BowEffects

let SCRIPT_NAME = "nef-playground-book"

func main() {
    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (packageContent: String, projectName: String, output: URL)> {
        console.arguments(keys: ["name", "package", "output"])
               .flatMap { args in
                    guard let projectName = args["name"],
                          let packagePath = args["package"]?.expandingTildeInPath,
                          let outputPath = args["output"]?.expandingTildeInPath,
                          let content = try? String(contentsOfFile: packagePath), !content.isEmpty
                    else { return console.exit(failure: "received an invalid Swift Package") }
                        
                    return IO.pure((packageContent: content,
                                    projectName: projectName,
                                    output: URL(fileURLWithPath: outputPath)))^
                
                }^.handleErrorWith { _ in console.help() }^
    }
    
    let console = Console(script: SCRIPT_NAME,
                          help:   """
                                  \(SCRIPT_NAME) --name <swift-playground name> --package <package path> --output <output path>

                                      name: name for the Swift Playground. ex. `nef`
                                      package: path to Package.swift file. ex. `/home/Package.swift`
                                      output: path where Playground is saved to. ex. `/home`

                                  """)
    
    _ = arguments(console: console)
            .flatMap { (packageContent, projectName, output) -> IO<CLIKit.Console.Error, Void> in
                nef.SwiftPlayground.render(packageContent: packageContent, name: projectName, output: output)
                                   .provide(console)^
                                   .mapLeft { _ in .render }
                                   .foldM({ _   in console.exit(failure: "rendering Playground Book")                  },
                                          { url in console.exit(success: "rendered Playground Book in '\(url.path)'")  }) }^
            .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
