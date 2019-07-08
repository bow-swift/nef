//  Copyright © 2019 The nef Authors.

import Foundation
import Core
import Common

let scriptName = "nef-markdown-page"
let console = MarkdownConsole()

func main() {
    let result = arguments(keys: "from", "to", "filename")
    guard let fromPage = result["from"],
          let output = result["to"],
          let filename = result["filename"] else {
            Console.help.show(output: console);
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/\(filename).md"

    renderMarkdown(from: from, to: to)
}

// #: - MAIN <launcher>
main()
