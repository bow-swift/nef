//  Copyright © 2019 The nef Authors.

import Foundation
import Markup
import Common

let scriptName = "nef-jekyll-page"
let console = JekyllConsole()

func main() {
    let result = arguments(keys: "from", "to", "permalink")
    guard let fromPage = result["from"],
          let output = result["to"],
          let permalink = result["permalink"] else {
            Console.help.show(output: console);
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/README.md"
    
    renderJekyll(from: from, to: to, permalink: permalink)
}

// #: - MAIN <launcher>
main()
