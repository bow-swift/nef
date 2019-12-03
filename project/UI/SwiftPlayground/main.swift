//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import BowEffects

let SCRIPT_NAME = "nef-swift-playground"

func main() {
    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (packageContent: String, projectName: String, output: URL)> {
        console.arguments(keys: ["package", "to", "name"])
               .flatMap { args in
                    guard let packagePath = args["package"]?.expandingTildeInPath,
                          let outputPath = args["to"]?.expandingTildeInPath,
                          let projectName = args["name"],
                          let content = try? String(contentsOfFile: packagePath), !content.isEmpty
                    else { return console.exit(failure: "received an invalid Swift Package") }
                        
                    return IO.pure((packageContent: content,
                                    projectName: projectName,
                                    output: URL(fileURLWithPath: outputPath)))^
                
                }^.handleErrorWith { _ in console.help() }^
    }
    
    let console = Console(script: SCRIPT_NAME,
                          help:   """
                                  \(SCRIPT_NAME) --package <package path> --to <output path> --name <swift-playground name>")

                                      package: path to Package.swift file. ex. `/home/Package.swift`
                                      to: path where Playground is saved to. ex. `/home`
                                      name: name for the Swift Playground. ex. `nef`

                                  """)
    
    _ = arguments(console: console)
            .flatMap { (packageContent, projectName, output) -> IO<CLIKit.Console.Error, Void> in
                nef.SwiftPlayground.render(packageContent: packageContent, name: projectName, output: output)
                                   .provide(console)^
                                   .mapLeft { _ in .render }
                                   .foldM({ _   in console.exit(failure: "render Playground Book")                  },
                                          { url in console.exit(success: "render Playground Book in '\(url.path)'") }) }^
            .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
