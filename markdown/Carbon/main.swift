//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

let scriptName = "nef-carbon-page"

func main() {
    let result = arguments(keys: "from", "to")
    guard let fromPage = result["from"],
          let output = result["to"] else {
            Console.help.show();
            exit(-1)
    }
    
    let from = "\(fromPage)/Contents.swift"
    let playgroundName = PlaygroundUtils.playgroundName(fromPage: from)
    let to = "\(output)\(playgroundName)".expandingTildeInPath
    
    renderCarbon(from: from, to: to)
}

/// Method to render a page into Carbon's images.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to render the snippets.
func renderCarbon(from filePath: String, to outputPath: String) {
    guard let content = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) else { Console.error.show(); return }
    
    let style = CarbonStyle(size: .x2)
    if let error = CarbonGenerator(style: style, output: outputPath).render(content: content) {
        
    } else {
        Console.success.show()
    }
}

// #: - MAIN <launcher>
main()






