//  Copyright © 2019 The nef Authors.

import Foundation
import Core
import Common

public enum NefMarkdown {
    static public func run(content: String, outputPath: String) {
        renderMarkdown(content: content, to: outputPath)
    }
}


/// Renders a page into Markdown format.
///
/// - Parameters:
///   - filePath: input page in Xcode playground format.
///   - outputPath: output where to write the Markdown render.
func renderMarkdown(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)
    
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
        let rendered = MarkdownGenerator().render(content: content),
        let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else {
            Console.error(information: "").show(output: console)
            return
    }
    
    Console.success.show(output: console)
}

/// Renders a page into Markdown format.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Markdown render.
private func renderMarkdown(content: String, to outputPath: String) {
    let outputURL = URL(fileURLWithPath: outputPath)
    
    guard let rendered = MarkdownGenerator().render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else {
            Console.error(information: "").show(output: console)
            return
    }
    
    Console.success.show(output: console)
}
