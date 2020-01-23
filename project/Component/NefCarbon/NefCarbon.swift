//  Copyright © 2019 The nef Authors.

import AppKit
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Carbon {
    public typealias Environment = RenderCarbonEnvironment<Image>
    typealias RenderingOutput = NefCommon.RenderingOutput<Image>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<Image>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<Image>
    
    public init() {}
}

/// Renders a page into multiple Carbon images.
///
/// - Parameters:
///   - code: snippet to export.
///   - style: style to apply to export code snippet.
///   - outputPath: output where to render the snippets.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
//public func renderCarbon(downloader: CarbonDownloader,
//                         code content: String,
//                         style: CarbonStyle,
//                         outputPath: String,
//                         success: @escaping (RendererOutput) -> Void, failure: @escaping (String) -> Void) {
//    
//    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
//    guard let rendered = carbonGenerator.render(content: content) else { failure("could not render carbon page '\(outputPath)'"); return }
//    carbonGenerator.isValid(trace: rendered.output) ? success(rendered) : failure(rendered.output)
//}
//
//
///// Get an URL Request given a carbon configuration
/////
///// - Parameter carbon: configuration
///// - Returns: URL request to carbon.now.sh
//public func carbonURLRequest(from carbon: CarbonModel) -> URLRequest {
//    return CarbonViewer.urlRequest(from: carbon)
//}

