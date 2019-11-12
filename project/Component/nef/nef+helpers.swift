//  Copyright © 2019 The nef Authors.

import AppKit

import NefMarkdown
import NefJekyll
import NefCarbon


// MARK: - Carbon <api>

/// Renders a code selection into multiple Carbon images.
///
/// - Precondition: this method must be invoked from main thread.
///
/// - Parameters:
///   - parentView: canvas view where to render Carbon image.
///   - code: content to generate the snippet.
///   - style: style to apply to exported code snippet.
///   - outputPath: output where to render the snippets.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
internal func carbon(parentView: NSView,
                    code: String,
                    style: CarbonStyle,
                    outputPath: String,
                    success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    guard Thread.isMainThread else {
        fatalError("carbon(parentView:code:style:outputPath:success:failure:) should be invoked in main thread")
    }
    
    let assembler = CarbonAssembler()
    let carbonView = assembler.resolveCarbonView(frame: parentView.bounds)
    let downloader = assembler.resolveCarbonDownloader(view: carbonView, multiFiles: false)
    
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
