//  Copyright © 2019 The nef Authors.

import Foundation

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
