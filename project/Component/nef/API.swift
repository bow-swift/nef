//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects

/// Instance of the Version API
public enum Version: VersionAPI {}

/// Instance of the Compiler API
public enum Compiler: CompilerAPI {}

/// Instance of the Clean API
public enum Clean: CleanAPI {}

/// Instance of the Markdown API
public enum Markdown: MarkdownAPI {}

/// Instance of the Jekyll API
public enum Jekyll: JekyllAPI {}

/// Instance of the Carbon API
public enum Carbon: CarbonAPI {}

/// Instance of the Playground API
public enum Playground: PlaygroundAPI {}

/// Instance of the Swift Playground API
public enum SwiftPlayground: SwiftPlaygroundAPI {}


/// Describes the API for `Version`
public protocol VersionAPI {
    /// Gets nef build version number.
    /// 
    /// - Returns: An IO that never produce errors and returns the build version number.
    static func info() -> UIO<String>
}

/// Describes the API for `Compiler`
public protocol CompilerAPI {
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playgrounds to be compiled.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: To use for the compiler.
    ///   - cached: Use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport,.
    static func compile(xcodePlayground: URL, platform: Platform, dependencies: PlaygroundDependencies, cached: Bool) -> EnvIO<ProgressReport, nef.Error, Void>
    
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - nefPlayground: Folder where to search Xcode Playgrounds - it must be a nef Playground structure.
    ///   - cached: Use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport,.
    static func compile(nefPlayground: URL, cached: Bool) -> EnvIO<ProgressReport, nef.Error, Void>
}

/// Describes the API for `Clean`
public protocol CleanAPI {
    /// Cleans a nef Playground.
    ///
    /// - Parameters:
    ///   - nefPlayground: Folder where to search for Xcode Playgrounds - it must be a nef Playground structure.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport`.
    static func clean(nefPlayground: URL) -> EnvIO<ProgressReport, nef.Error, Void>
}

/// Describes the API for `Markdown`
public protocol MarkdownAPI {
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String) -> EnvIO<ProgressReport, nef.Error, String>
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL) -> EnvIO<ProgressReport, nef.Error, String>
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String) -> EnvIO<ProgressReport, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL) -> EnvIO<ProgressReport, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - into: Folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playground: URL, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - into: Folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playgroundsAt: URL, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
}

/// Describes the API for `Jekyll`
public protocol JekyllAPI {
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String, permalink: String) -> EnvIO<ProgressReport, nef.Error, String>
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL, permalink: String) -> EnvIO<ProgressReport, nef.Error, String>
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String, permalink: String) -> EnvIO<ProgressReport, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL, permalink: String) -> EnvIO<ProgressReport, nef.Error, (ast: String, rendered: String)>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String, permalink: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL, permalink: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL, permalink: String, toFile file: URL) -> EnvIO<ProgressReport, nef.Error, (url: URL, ast: String, rendered: String)>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - into: Folder where to render the jekyll files (for each playground's page).
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playground: URL, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - mainPage: The main page path (in jekyll file format).
    ///   - into: Folder where to render the jekyll site.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
}

/// Describes the API for `Carbon`
public protocol CarbonAPI {
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the images generated of type `NEA<Data>`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, NEA<Data>>
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the images generated of type `NEA<Data>`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, NEA<Data>>
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, (ast: String, images: NEA<Data>)>
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, (ast: String, images: NEA<Data>)>
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: Code to render into Carbon image.
    ///   - style: Style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the image generated of type `Data`, having access to an immutable environment of type `ProgressReport`.
    static func render(code: String, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, Data>
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: Code to render into Carbon image.
    ///   - style: Style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(code: String, style: CarbonStyle) -> EnvIO<ProgressReport, nef.Error, (ast: String, image: Data)>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(page: URL, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<ProgressReport, nef.Error, (ast: String, url: URL)>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(page: URL, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<ProgressReport, nef.Error, (ast: String, url: URL)>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - into: Folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the carbon files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playground: URL, style: CarbonStyle, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - style: Style to apply to the generated snippets.
    ///   - into: Folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the list of playgrounds rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(playgroundsAt: URL, style: CarbonStyle, into output: URL) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Get an URL Request given a carbon configuration
    ///
    /// - Parameter carbon: Configuration.
    /// - Returns: URL request to carbon.now.sh
    static func request(configuration: CarbonModel) -> URLRequest
    
    /// Get a `NSView` given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: View of type `NSView`
    static func view(configuration: CarbonModel) -> CarbonView
}

/// Describes the API for `Playground`
public protocol PlaygroundAPI {
    /// Make a nef Playground compatible with 3rd-party libraries.
    ///
    /// - Parameters:
    ///   - name: Name for the output nef Playground.
    ///   - output: Folder where to write the nef Playground.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: Dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Make a nef Playground compatible with 3rd-party libraries from an Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playground to transform to nef Playground.
    ///   - name: Name for the output nef Playground.
    ///   - output: Folder where to write the nef Playground.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: Dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func nef(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<ProgressReport, nef.Error, URL>
}

/// Describes the API for `Swift Playground`
public protocol SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(packageContent: String, name: String, output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - package: Swift Package file.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(package: URL, name: String, output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    ///   - excludes: List of items to exclude for building the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`. 
    static func render(packageContent: String, name: String, output: URL, excludes: [PlaygroundExcludeItem]) -> EnvIO<ProgressReport, nef.Error, URL>
}
