//  Copyright © 2019 The nef Authors.

import Foundation

/// Renders a page into multiple Carbon images.
///
/// - Parameters:
///   - code: snippet to export.
///   - style: style to apply to export code snippet.
///   - outputPath: output where to render the snippets.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func renderCarbon(downloader: CarbonDownloader, code content: String, style: CarbonStyle, outputPath: String,
                         success: @escaping () -> Void, failure: @escaping (String) -> Void) {
    
    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
    guard let trace = carbonGenerator.render(content: content) else { failure(""); return }
    carbonGenerator.isValid(trace: trace) ? success() : failure(trace)
}


/// Get an URL Request given a carbon configuration
///
/// - Parameter carbon: configuration
/// - Returns: URL request to carbon.now.sh
public func carbonURLRequest(from carbon: Carbon) -> URLRequest {
    return CarbonViewer.urlRequest(from: carbon)
}