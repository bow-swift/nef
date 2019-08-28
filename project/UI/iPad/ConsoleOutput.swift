//  Copyright © 2019 The nef Authors.

import Foundation
import Common

class iPadConsole: ConsoleOutput {

    func printError(information: String) {
        if !information.isEmpty {
            print("information: \(information)")
        }
        print("error:\(scriptName) could not build Playground compatible with iPad ❌")
    }

    func printHelp() {
        print("\(scriptName) --package <package path> --to <output path> --name <playground name>")
        print("""

                    package: path to Package.swift page. ex. `/home/Package.swift`
                    to: path where Playground are saved to. ex. `/home`
                    name: name for the Playground. ex. `Nef`

              """)
    }
    
    func printStep(information: String) {
        print(information, separator: " ", terminator: "")
    }
    
    func printSubstep(information: String) {
        print("\t\(information)", separator: " ", terminator: "\n")
    }
    
    func printStatus(success: Bool) {
        print(" \(success ? "✅" : "❌")", separator: "", terminator: "\n")
    }
}
