//  Copyright © 2019 The nef Authors.

import AppKit
import NefCarbon
import Markup

// MARK: Carbon <api>
public func carbon(code: String,
                   style: CarbonStyle,
                   outputPath: String,
                   success: @escaping () -> Void, failure: @escaping () -> Void) -> NSWindow {
    
    let assembler = CarbonAssembler()
    let window = assembler.resolveWindow()
    
    carbon(parentView: window.contentView!,
           code: code,
           style: style,
           outputPath: outputPath,
           success: success, failure: failure)
    
    return window
}

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
