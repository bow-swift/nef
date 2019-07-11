//  Copyright © 2019 The nef Authors.

import Foundation
import Core

/// Renders a page into Markdown format.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Markdown render.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func renderMarkdown(content: String, to outputPath: String,
                            success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    let outputURL = URL(fileURLWithPath: outputPath)
    guard let rendered = MarkdownGenerator().render(content: content) else { failure("can not render markdown from input"); return }
    guard let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { failure("invalid output path"); return }
    
    success()
}
