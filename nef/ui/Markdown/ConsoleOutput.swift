//  Copyright © 2019 The nef Authors.

import Foundation
import Common

class MarkdownConsole: ConsoleOutput {

    func printError(information: String) {
        if !information.isEmpty {
            print("information: \(information)")
        }
        print("error:\(scriptName) could not render the Markdown file ❌")
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output path> --filename <markdown's filename>")
        print("""

                    from: path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: path where markdown are saved to. ex. `/home`
                    filename: name for the rendered Markdown file (without any extension). ex. `Readme`

              """)
    }
}
