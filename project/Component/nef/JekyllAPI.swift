//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
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
                        verbose: false,
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
    ///   - verbose: run in verbose mode.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    static func jekyll(content: String, to outputPath: String, permalink: String, verbose: Bool, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("jekyll(content:outputPath:permalink:success:failure:) should be invoked in main thread")
        }
        
        renderJekyll(content: content,
                     to: outputPath,
                     permalink: permalink,
                     verbose: verbose,
                     success: success,
                     failure: failure)
    }
}
