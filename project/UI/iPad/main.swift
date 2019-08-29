//  Copyright © 2019 The nef Authors.

import Foundation
import Common

let scriptName = "nef-playground-ipad"
let console = iPadConsole()

func main() {
    let args = arguments(keys: "package", "to", "name")
    guard let packagePath = args["package"],
          let outputPath = args["to"],
          let projectName = args["name"] else {
            Console.help.show(output: console)
            return
    }
    
    let playground = Playground(packagePath: packagePath, projectName: projectName, outputPath: outputPath, console: console)
    let result = playground.build(cached: true)
    
    if case let .failure(error) = result {
        Console.error(information: error.information).show(output: console)
        exit(-1)
    }
}

// #: - MAIN <launcher>
main()
