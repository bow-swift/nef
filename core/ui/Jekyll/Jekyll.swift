//  Copyright © 2019 The nef Authors.

import Foundation
import Markup
import Common

public enum NefJekyll {
    static public func run(content: String, outputPath: String, permalink: String) {
        renderJekyll(content: content, to: outputPath, permalink: permalink)
    }
}


/// Method to render a page into Jekyll format.
///
/// - Parameters:
///   - filePath: input page in Apple's playgorund format.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website's relative url where locate the page.
func renderJekyll(from filePath: String, to outputPath: String, permalink: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)
    
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
        let rendered = JekyllGenerator(permalink: permalink).render(content: content),
        let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { Console.error(information: "").show(output: console); return }
    
    Console.success.show(output: JekyllConsole())
}

/// Method to render a page into Jekyll format.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website's relative url where locate the page.
private func renderJekyll(content: String, to outputPath: String, permalink: String) {
    let outputURL = URL(fileURLWithPath: outputPath)
    
    guard let rendered = JekyllGenerator(permalink: permalink).render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else {
            Console.error(information: "").show(output: console)
            return
    }
    
    Console.success.show(output: console)
}
