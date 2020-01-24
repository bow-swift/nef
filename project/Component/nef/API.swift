//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects


public enum Markdown: MarkdownAPI {}
public enum Jekyll: JekyllAPI {}
public enum Carbon: CarbonAPI {}
public enum SwiftPlayground: SwiftPlaygroundAPI {}


public protocol MarkdownAPI {
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the markdown generated of type `String`, having access to an immutable environment of type `Console`.
    static func render(content: String) -> EnvIO<Console, nef.Error, String>
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(content: String) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - toFile: output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the file generated of type `URL`, having access to an immutable environment of type `Console`.
    static func render(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - toFile: output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playground: path to Xcode playground.
    ///   - into: folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the markdown files generated of type `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: folder where to search Xcode Playgrounds (recursive search).
    ///   - into: folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the playground paths rendered `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playgroundsAt: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
}

public protocol JekyllAPI {
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - permalink: relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the jekyll generated of type `String`, having access to an immutable environment of type `Console`.
    static func render(content: String, permalink: String) -> EnvIO<Console, nef.Error, String>
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - permalink: relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(content: String, permalink: String) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - permalink: relative url where locate the page.
    ///   - toFile: output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the file generated of type `URL`, having access to an immutable environment of type `Console`.
    static func render(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - permalink: relative url where locate the page.
    ///   - toFile: output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playground: path to Xcode playground.
    ///   - into: folder where to render the jekyll files (for each playground's page).
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the jekyll files generated of type `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: folder where to search Xcode Playgrounds (recursive search).
    ///   - mainPage: the main page path (in jekyll file format).
    ///   - into: folder where to render the jekyll site.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the playground paths rendered `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]>
}

public protocol CarbonAPI {
    /// Renders a code selection into Carbon image.
    ///
    /// - Precondition: this method must be invoked from background thread.
    ///
    /// - Parameters:
    ///   - carbon: content+style to generate code snippet.
    ///   - file: output where to render the snippets (path to the file without extension).
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `nef.Error` and values with the file generated of type `URL`.
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

public protocol SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content
    ///   - name: name for the output Swift Playground
    ///   - output: folder where to write the Swift Playground
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `Console`. It can be seen as a Kleisli function `(Console) -> IO<nef.Error, URL>`.
    static func render(packageContent: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content
    ///   - name: name for the output Swift Playground
    ///   - output: folder where to write the Swift Playground
    ///   - excludes: list of items to exclude for building the Swift Playground
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `Console`. It can be seen as a Kleisli function `(Console) -> IO<nef.Error, URL>`.
    static func render(packageContent: String, name: String, output: URL, excludes: [PlaygroundExcludeItem]) -> EnvIO<Console, nef.Error, URL>
}
