//  Copyright © 2019 The nef Authors.

import Foundation

extension ConsoleOutput {

    func printError(information: String) {
        print("""
              error:\(scriptName) could not render the Carbon's snippets ❌
              trace: \(information)
              """)
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output carbon>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: is the path where render the Carbon's snippets. ex. `/home`

             """)
    }
}
