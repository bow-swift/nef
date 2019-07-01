//  Copyright © 2019 The nef Authors.

import Foundation
import Common

class JekyllConsole: ConsoleOutput {

    func printError(information: String) {
        if !information.isEmpty {
            print("information: \(information)")
        }
        print("error:\(scriptName) could not render the Jekyll's file ❌")
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output Jekyll's markdown> --permalink <relative URL>")
        print("""

                    from: path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: path where Jekyll markdown are saved to. ex. `/home`
                    permalink: is the relative path where Jekyll will render the documentation. ex. `/about/`

              """)
    }
}
