//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects


public enum Markdown: MarkdownAPI {}
public enum Jekyll: JekyllAPI {}
public enum Carbon: CarbonAPI {}


public protocol MarkdownAPI {
    /// Renders content into Markdown file.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - file: output where to write the Markdown render (path to the file without extension).
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `PageError` and values with the file generated of type `URL`.
    static func render(content: String, toFile file: URL) -> IO<nef.Error, URL>
}

public protocol JekyllAPI {
    /// Renders content into Jekyll format.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - file: output where to write the Markdown render (path to the file without extension).
    ///   - permalink: website relative url where locate the page.
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `PageError` and values with the file generated of type `URL`.
    static func render(content: String, toFile file: URL, permalink: String) -> IO<nef.Error, URL>
}

public protocol CarbonAPI {
    /// Renders a code selection into Carbon image.
    ///
    /// - Precondition: this method must be invoked from background thread.
    ///
    /// - Parameters:
    ///   - carbon: content+style to generate code snippet.
    ///   - file: output where to render the snippets (path to the file without extension).
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `CarbonError.Cause` and values with the file generated of type `URL`.
    static func render(carbon: CarbonModel, toFile file: URL) -> IO<nef.Error, URL>
    
    /// Get an URL Request given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: URL request to carbon.now.sh
    static func request(with configuration: CarbonModel) -> URLRequest
    
    /// Get a NSView given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: NSView
    static func view(with configuration: CarbonModel) -> CarbonView
}
