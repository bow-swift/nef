//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects


public enum Compiler: CompilerAPI {}
public enum Markdown: MarkdownAPI {}
public enum Jekyll: JekyllAPI {}
public enum Carbon: CarbonAPI {}
public enum Playground: PlaygroundAPI {}
public enum SwiftPlayground: SwiftPlaygroundAPI {}


public protocol CompilerAPI {
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playgrounds to be compiled.
    ///   - platform: target to use for compiling Xcode Playground.
    ///   - dependencies: to use for the compiler.
    ///   - cached: use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `Console`.
    static func compile(xcodePlayground: URL, platform: Platform, dependencies: PlaygroundDependencies, cached: Bool) -> EnvIO<Console, nef.Error, Void>
    
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - nefPlayground: folder where to search Xcode Playgrounds - it must be a nef Playground structure.
    ///   - cached: use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `Console`.
    static func compile(nefPlayground: URL, cached: Bool) -> EnvIO<Console, nef.Error, Void>
}

public protocol MarkdownAPI {
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown generated of type `String`, having access to an immutable environment of type `Console`.
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
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `Console`.
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
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown files generated of type `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: folder where to search Xcode Playgrounds (recursive search).
    ///   - into: folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playgroundsAt: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
}

public protocol JekyllAPI {
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - permalink: relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll generated of type `String`, having access to an immutable environment of type `Console`.
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
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `Console`.
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
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll files generated of type `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: folder where to search Xcode Playgrounds (recursive search).
    ///   - mainPage: the main page path (in jekyll file format).
    ///   - into: folder where to render the jekyll site.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
}

public protocol CarbonAPI {
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - style: style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the images generated of type `NEA<Data>`, having access to an immutable environment of type `Console`.
    static func render(content: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, NEA<Data>>
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - style: style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(content: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, (ast: String, images: NEA<Data>)>
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: code to render into Carbon image.
    ///   - style: style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the image generated of type `Data`, having access to an immutable environment of type `Console`.
    static func render(code: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, Data>
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: code to render into Carbon image.
    ///   - style: style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.
    static func renderVerbose(code: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, (ast: String, image: Data)>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - style: style to apply to the generated snippets.
    ///   - filename: name to use in the exported carbon images.
    ///   - into: folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `Console`.
    static func render(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<Console, nef.Error, URL>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - style: style to apply to the generated snippets.
    ///   - filename: name to use in the exported carbon images.
    ///   - into: folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `Console`.   
    static func renderVerbose(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<Console, nef.Error, (ast: String, url: URL)>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playground: path to Xcode playground.
    ///   - style: style to apply to the generated snippets.
    ///   - into: folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the carbon files generated of type `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playground: URL, style: CarbonStyle, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playgroundsAt: folder where to search Xcode Playgrounds (recursive search).
    ///   - style: style to apply to the generated snippets.
    ///   - into: folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the list of playgrounds rendered `[URL]`, having access to an immutable environment of type `Console`.
    static func render(playgroundsAt: URL, style: CarbonStyle, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>>
    
    /// Get an URL Request given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: URL request to carbon.now.sh
    static func request(configuration: CarbonModel) -> URLRequest
    
    /// Get a `NSView` given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: view of type `NSView`
    static func view(configuration: CarbonModel) -> CarbonView
}

public protocol PlaygroundAPI {
    /// Make a nef Playground compatible with 3rd-party libraries.
    ///
    /// - Parameters:
    ///   - name: name for the output nef Playground.
    ///   - output: folder where to write the nef Playground.
    ///   - platform: target to use for compiling Xcode Playground.
    ///   - dependencies: dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `Console`.
    static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL>
    
    /// Make a nef Playground compatible with 3rd-party libraries from an Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playground to transform to nef Playground.
    ///   - name: name for the output nef Playground.
    ///   - output: folder where to write the nef Playground.
    ///   - platform: target to use for compiling Xcode Playground.
    ///   - dependencies: dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `Console`.
    static func nef(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL>
}

public protocol SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: name for the output Swift Playground.
    ///   - output: folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `Console`. It can be seen as a Kleisli function `(Console) -> IO<nef.Error, URL>`.
    static func render(packageContent: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: name for the output Swift Playground.
    ///   - output: folder where to write the Swift Playground.
    ///   - excludes: list of items to exclude for building the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `Console`. It can be seen as a Kleisli function `(Console) -> IO<nef.Error, URL>`.
    static func render(packageContent: String, name: String, output: URL, excludes: [PlaygroundExcludeItem]) -> EnvIO<Console, nef.Error, URL>
}
