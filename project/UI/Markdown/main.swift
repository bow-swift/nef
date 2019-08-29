//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Core
import NefMarkdown

let scriptName = "nef-markdown-page"
let console = MarkdownConsole()

func main() {
    let result = arguments(keys: "from", "to", "filename")
    guard let fromPage = result["from"],
          let output = result["to"],
          let filename = result["filename"] else {
            console.printHelp()
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/\(filename).md"

    renderMarkdown(from: from, to: to)
}

/// Renders a page into Markdown format.
///
/// - Parameters:
///   - filePath: input page in Xcode playground format.
///   - outputPath: output where to write the Markdown render.
private func renderMarkdown(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
        console.printError(information: "invalid input file '\(filePath)'")
        return
    }
    
    renderMarkdown(content: content,
                   to: outputPath,
                   success: { console.printSuccess() },
                   failure: { console.printError(information: $0) })
}

// #: - MAIN <launcher>
main()
