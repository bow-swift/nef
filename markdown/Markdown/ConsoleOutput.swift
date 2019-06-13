//  Copyright © 2019 The nef Authors.

import Foundation

extension ConsoleOutput {

    func printError(information: String) {
        if !information.isEmpty {
            print("information: \(information)")
        }
        print("error:\(scriptName) could not render the Markdown file ❌")
    }

    func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output path> --filename <markdown's filename>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: path where Carbon snippets are saved to. ex. `/home`
                    to: is the path where render the markdown. ex. `/home`
                    filename: name for the rendered Markdown file (without any extension). ex. `Readme`

             """)
    }
}
