//  Copyright © 2019 The nef Authors.

import AppKit

import NefMarkdown
import NefJekyll
import NefCarbon
import NefModels


// MARK: - Markdown <api>

/// Renders content into Markdown files.
///
/// - Precondition: this method must be invoked from main thread.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Markdown render.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func markdown(content: String, to outputPath: String,
                     success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    guard Thread.isMainThread else {
        fatalError("markdown(content:outputPath:success:failure:) should be invoked in main thread")
    }
    
    renderMarkdown(content: content,
                   to: outputPath,
                   success: success,
                   failure: failure)
}


// MARK: - Jekyll <api>

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
public func jekyll(content: String, to outputPath: String, permalink: String,
                   success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    guard Thread.isMainThread else {
        fatalError("jekyll(content:outputPath:permalink:success:failure:) should be invoked in main thread")
    }
    
    renderJekyll(content: content,
                 to: outputPath,
                 permalink: permalink,
                 success: success,
                 failure: failure)
}


// MARK: - Carbon <api>

/// Renders a code selection into multiple Carbon images.
///
/// - Precondition: this method must be invoked from main thread.
///
/// - Parameters:
///   - code: content to generate the snippet.
///   - style: style to apply to exported code snippet.
///   - outputPath: output where to render the snippets.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func carbon(code: String,
                   style: CarbonStyle,
                   outputPath: String,
                   success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    guard Thread.isMainThread else {
        fatalError("carbon(code:style:outputPath:success:failure:) should be invoked in main thread")
    }
    
    let assembler = CarbonAssembler()
    let window = assembler.resolveWindow()
    let view = window.contentView!
    let retainSuccess = { success(); _ = view }
    let retainFailure = { (output: String) in failure(output); _ = view }
    
    carbon(parentView: view,
           code: code,
           style: style,
           outputPath: outputPath,
           success: retainSuccess, failure: retainFailure)
}

/// Get an URL Request given a carbon configuration
///
/// - Parameter carbon: configuration
/// - Returns: URL request to carbon.now.sh
public func carbonURLRequest(withConfiguration carbon: Carbon) -> URLRequest {
    return CarbonViewer.urlRequest(from: carbon)
}
