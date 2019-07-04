//  Copyright © 2019 The nef Authors.

import AppKit
import NefCarbon
import Markup

//    static public func markdown(content: String, outputPath: String) {
//        NefMarkdown.run(content: content, outputPath: outputPath)
//    }
//
//    static public func jekyll(content: String, outputPath: String, permalink: String) {
//        NefJekyll.run(content: content, outputPath: outputPath, permalink: permalink)
//    }
//

// MARK: Carbon <api>
public func carbon(parentView: NSView,
                   code: String,
                   style: CarbonStyle,
                   outputPath: String,
                   success: @escaping () -> Void, failure: @escaping () -> Void) {
    
    let assembler = CarbonAssembler()
    let carbonView = assembler.resolveCarbonView(frame: parentView.bounds)
    let downloader = assembler.resolveCarbonDownloader(view: carbonView)
    
    parentView.addSubview(carbonView)
    
    DispatchQueue(label: "nef-framework", qos: .userInitiated).async {
        renderCarbon(downloader: downloader,
                     code: "\(code)\n",
                     style: style,
                     outputPath: outputPath,
                     success: success,
                     failure: failure)
    }
}
