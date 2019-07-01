//  Copyright © 2019 The nef Authors.

import Foundation
import NefCarbon
import Markup

public enum nef {
//    static public func markdown(content: String, outputPath: String) {
//        NefMarkdown.run(content: content, outputPath: outputPath)
//    }
//    
//    static public func jekyll(content: String, outputPath: String, permalink: String) {
//        NefJekyll.run(content: content, outputPath: outputPath, permalink: permalink)
//    }
//    
    static public func carbon(code: String, style: CarbonStyle, outputPath: String) {
        _ = CarbonApplication { downloader in
            renderCarbon(downloader: downloader, code: code, style: style, outputPath: outputPath)
        }
    }
}
