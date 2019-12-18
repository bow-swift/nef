//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefMarkdown

import Bow
import BowEffects

public extension MarkdownAPI {
    
    static func render(content: String, toFile file: URL) -> IO<nef.Error, URL> {
        IO.async { callback in
            let output = URL(fileURLWithPath: "\(file.path).md")
            self.markdown(content: content,
                          to: output.path,
                          success: {
                            let fileExist = FileManager.default.fileExists(atPath: output.path)
                            fileExist ? callback(.right(output)) : callback(.left(.markdown))
                          },
                          failure: { error in
                            callback(.left(.markdown))
                          })
        }^
    }
}

// MARK: - Helpers
fileprivate extension MarkdownAPI {
    
    /// Renders content into Markdown file.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - outputPath: output where to write the Markdown render.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    static func markdown(content: String, to outputPath: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("markdown(content:outputPath:success:failure:) should be invoked in main thread")
        }
        
        renderMarkdown(content: content,
                       to: outputPath,
                       success: { _ in success() },
                       failure: failure)
    }
}
