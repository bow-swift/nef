//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefMarkdown
import NefJekyll

import Bow
import BowEffects


public extension PageAPI {
    
    func markdown(content: String, to outputPath: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("markdown(content:outputPath:success:failure:) should be invoked in main thread")
        }
        
        renderMarkdown(content: content,
                       to: outputPath,
                       success: success,
                       failure: failure)
    }

    func jekyll(content: String, to outputPath: String, permalink: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("jekyll(content:outputPath:permalink:success:failure:) should be invoked in main thread")
        }
        
        renderJekyll(content: content,
                     to: outputPath,
                     permalink: permalink,
                     success: success,
                     failure: failure)
    }
}

public extension PageFP where Self: PageAPI {
    
    func markdownIO(content: String, toFile file: URL) -> IO<nef.Error, URL> {
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
    
    func jekyllIO(content: String, toFile file: URL, permalink: String) -> IO<nef.Error, URL> {
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
