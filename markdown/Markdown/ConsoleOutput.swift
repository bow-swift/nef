//  Copyright © 2019 The nef Authors.

import Foundation

extension ConsoleOutput {
    func printError() {
        print("error:\(scriptName) could not render the Markdown file ❌")
    }

    func printSuccess() {
        print("RENDER SUCCEEDED")
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output markdown's file>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: is the path where render the markdown. ex. `/home`

             """)
    }
}

