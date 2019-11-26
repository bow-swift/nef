//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef

let scriptName = "nef-swift-playground"
let console = iPadConsole()

func main() {
    let args = arguments(keys: "package", "to", "name")
    guard let packagePath = args["package"]?.expandingTildeInPath,
          let outputPath = args["to"]?.expandingTildeInPath,
          let projectName = args["name"] else {
            Console.help.show(output: console)
            exit(-1)
    }
    
    guard let content = try? String(contentsOfFile: packagePath), !content.isEmpty else {
        Console.error(information: "received an invalid Swift Package - '\(packagePath)'").show(output: console)
        exit(-1)
    }
    
    nef.SwiftPlayground.render(packageContent: content, name: projectName, output: URL(fileURLWithPath: outputPath))
                       .provide(console)
                       .unsafeRunSyncEither()
                       .fold({ error in console.printError(information: ""); exit(-1) },
                             { _ in console.printSuccess(); exit(0) })
}

// #: - MAIN <launcher>
main()
