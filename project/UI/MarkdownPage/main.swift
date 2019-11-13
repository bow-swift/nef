//  Copyright © 2019 The nef Authors.

import Foundation
import CLIKit

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

/// Renders a page into Markdown format.
///
/// - Parameters:
///   - filePath: input page in Xcode playground format.
///   - outputPath: output where to write the Markdown render.
private func renderMarkdown(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
        Console.error(information: "invalid input file '\(filePath)'").show(output: console)
        return
    }
    
    renderMarkdown(content: content,
                   to: outputPath,
                   success: { Console.success.show(output: console) },
                   failure: { Console.error(information: $0).show(output: console) })
}

// #: - MAIN <launcher>
main()
