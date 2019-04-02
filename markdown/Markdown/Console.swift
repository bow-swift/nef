//
//  Console.swift
//  Markdown
//
//  Created by Miguel Ángel Díaz on 29/03/2019.
//  Copyright © 2019 47 Degrees. All rights reserved.
//

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

