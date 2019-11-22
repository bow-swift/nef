//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import NefSwiftPlayground

let scriptName = "nef-swift-playground"
let console = iPadConsole()

func main() {
    let args = arguments(keys: "package", "to", "name")
    guard let packagePath = args["package"],
          let outputPath = args["to"],
          let projectName = args["name"] else {
            Console.help.show(output: console)
            exit(-1)
    }
    
    guard let package = try? String(contentsOfFile: packagePath), !package.isEmpty else {
        Console.error(information: "received an invalid Swift Package - '\(packagePath)'").show(output: console)
        exit(-1)
    }
    
    SwiftPlayground(packageContent: package, name: projectName, output: URL(fileURLWithPath: outputPath))
                .build(cached: true)
                .provide(console)
                .unsafeRunSyncEither()
                .fold({ error in
                    console.printError(information: error.information); exit(-1)
                 }, {
                    console.printSuccess(); exit(0)
                 })
}

// #: - MAIN <launcher>
main()
