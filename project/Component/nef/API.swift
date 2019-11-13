//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects


public enum Render: RenderAPI, RenderFP {
    case api
    public enum Page: PageAPI {
        case api
    }
}


public protocol RenderAPI {
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
    func carbon(code: String, style: CarbonStyle, outputPath: String, success: @escaping () -> Void, failure: @escaping (String) -> Void)
    
    /// Get an URL Request given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: URL request to carbon.now.sh
    func carbonURLRequest(withConfiguration carbon: Carbon) -> URLRequest
}

public protocol RenderFP: RenderAPI {
    /// Renders a code selection into multiple Carbon images.
    ///
    /// - Precondition: this method must be invoked from background thread.
    ///
    /// - Parameters:
    ///   - carbon: content+style to generate code snippet.
    ///   - output: output where to render the snippets.
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `CarbonError.Option` and values with the file generated of type `URL`.
    func carbonIO(_ carbon: Carbon, output: URL) -> IO<CarbonError.Option, URL>
}

public protocol PageAPI {
    /// Renders content into Markdown file.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - outputPath: output where to write the Markdown render.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    func markdown(content: String, to outputPath: String, success: @escaping () -> Void, failure: @escaping (String) -> Void)
    
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
    func jekyll(content: String, to outputPath: String, permalink: String, success: @escaping () -> Void, failure: @escaping (String) -> Void)
}
