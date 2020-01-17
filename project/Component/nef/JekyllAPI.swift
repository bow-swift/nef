//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefRender
import NefJekyll

import Bow
import BowEffects

public extension JekyllAPI {
    
    static func render(content: String, toFile file: URL, permalink: String) -> IO<nef.Error, URL> {
        IO.async { callback in
            let output = URL(fileURLWithPath: "\(file.path).md")
            self.jekyll(content: content,
                        to: output.path,
                        permalink: permalink,
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
fileprivate extension JekyllAPI {
    
    /// Renders content into Jekyll format.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - outputPath: output where to write the Markdown render.
    ///   - permalink: website relative url where locate the page.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    static func jekyll(content: String, to outputPath: String, permalink: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("jekyll(content:outputPath:permalink:success:failure:) should be invoked in main thread")
        }
        
        renderJekyll(content: content,
                     to: outputPath,
                     permalink: permalink,
                     success: { _ in success() },
                     failure: failure)
    }
}
