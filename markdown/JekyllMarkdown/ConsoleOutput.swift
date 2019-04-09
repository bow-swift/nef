//  Copyright © 2019 The nef Authors.

import Foundation

extension ConsoleOutput {

    func printError() {
        print("error:\(scriptName) could not render the Jekyll's file ❌")
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output Jekyll's markdown> --permalink <relative URL>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: is the path where render the Jekyll markdown. ex. `/home`
                    permalink: is the relative path where Jekyll will render the documentation. ex. `/about/`

             """)
    }
}
