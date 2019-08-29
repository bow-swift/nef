//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Core
import NefJekyll

let scriptName = "nef-jekyll-page"
let console = JekyllConsole()

func main() {
    let result = arguments(keys: "from", "to", "permalink")
    guard let fromPage = result["from"],
          let output = result["to"],
          let permalink = result["permalink"] else {
            console.printHelp()
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/README.md"
    
    renderJekyll(from: from, to: to, permalink: permalink)
}

/// Renders a page into Jekyll format.
///
/// - Parameters:
///   - filePath: input page in Xcode playgorund format.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website relative url where locate the page.
func renderJekyll(from filePath: String, to outputPath: String, permalink: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
        console.printError(information: "invalid input file '\(filePath)'")
        return
    }
    
    renderJekyll(content: content,
                 to: outputPath,
                 permalink: permalink,
                 success: { console.printSuccess() },
                 failure: { console.printError(information: $0) })
}

// #: - MAIN <launcher>
main()
