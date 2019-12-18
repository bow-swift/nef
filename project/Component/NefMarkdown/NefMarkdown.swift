//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore

/// Renders a page into Markdown format.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Markdown render.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func renderMarkdown(content: String,
                           to outputPath: String,
                           success: @escaping (RenderOutput) -> Void,
                           failure: @escaping (String) -> Void) {
    
    let url = URL(fileURLWithPath: outputPath)
    guard let rendered = MarkdownGenerator().render(content: content) else { failure("can not render input page into markdown file"); return }
    guard let _ = try? rendered.output.write(to: url, atomically: true, encoding: .utf8) else { failure("invalid output path '\(url.path)'"); return }
    
    success(rendered)
}
