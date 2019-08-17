//  Copyright © 2019 The nef Authors.

import Foundation
import Common

let scriptName = "nef-playground-ipad"
let console = iPadConsole()

func main() {
    let result = arguments(keys: "package", "to", "name")
    guard let packagePath = result["package"],
          let outputPath = result["to"],
          let projectName = result["name"] else {
            Console.help.show(output: console)
            exit(-1)
    }
    
    let playground = Playground(packagePath: packagePath, projectName: projectName, outputPath: outputPath)
    if let error = playground.build() {
        Console.error(information: error.information).show(output: console)
    } else {
        Console.success.show(output: console)
    }
}

// #: - MAIN <launcher>
main()
