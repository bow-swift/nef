//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit
import nef
import BowEffects

class iPadConsole: NefModels.Console {
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        IO.invoke { print(information, separator: " ", terminator: "") }
    }
    
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.invoke { information.forEach { item in print("\t• \(item)", separator: " ", terminator: "\n") } }
    }
    
    func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        IO.invoke { print(" \(success ? "✅" : "❌")", separator: "", terminator: "\n") }
    }
    
    func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        IO.invoke { print(" \(success ? "(\(information)) ✅" : "(\(information)) ❌")", separator: "", terminator: "\n") }
    }
}

extension iPadConsole: ConsoleOutput {
    func printError(information: String) {
        if !information.isEmpty {
            print("information: \(information)")
        }
        print("error:\(scriptName) could not build Swift Playground compatible with iPad ❌")
    }

    func printHelp() {
        print("\(scriptName) --package <package path> --to <output path> --name <swift-playground name>")
        print("""

                    package: path to Package.swift page. ex. `/home/Package.swift`
                    to: path where Playground are saved to. ex. `/home`
                    name: name for the Swift Playground. ex. `nef`

              """)
    }
}
