//  Copyright © 2020 The nef Authors.

import AppKit
import NefCore
@_exported import NefModels
import NefRender
import NefCarbon

import Bow
import BowEffects

/// Describes the API for `Carbon`
public protocol CarbonAPI {
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, images: NEA<Data>)>
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String,
        style: CarbonStyle,
        filename: String,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, url: URL)>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - into: Folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the carbon files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playground: URL,
        style: CarbonStyle,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - style: Style to apply to the generated snippets.
    ///   - into: Folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the list of playgrounds rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playgroundsAt: URL,
        style: CarbonStyle,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
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

public extension CarbonAPI {
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the images generated of type `NEA<Data>`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, NEA<Data>> {
        
        renderVerbose(content: content, style: style)
            .map { info in info.images }^
    }
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the images generated of type `NEA<Data>`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, NEA<Data>> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.carbon(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, style: style)
    }
    
    /// Renders a page into Carbon images.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, images: NEA<Data>)> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.carbon(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, style: style)
    }
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: Code to render into Carbon image.
    ///   - style: Style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the image generated of type `Data`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        code: String,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, Data> {
        
        renderVerbose(code: code, style: style)
            .map { info in info.image }^
    }
    
    /// Renders a code selection into Carbon image.
    ///
    /// - Parameters:
    ///   - code: Code to render into Carbon image.
    ///   - style: Style to apply to the generated snippet.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        code: String,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, image: Data)> {
        
        renderVerbose(content: code, style: style).map { output in (ast: output.ast, image: output.images.head) }^
    }
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String,
        style: CarbonStyle,
        filename: String,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        renderVerbose(
            content: content,
            style: style,
            filename: filename,
            into: output)
            .map { output in output.url }^
    }
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL,
        style: CarbonStyle,
        filename: String,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.carbon(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, style: style, filename: filename, into: output)
    }
    
    /// Renders a page into Carbon images and persit them.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - style: Style to apply to the generated snippets.
    ///   - filename: Name to use in the exported carbon images.
    ///   - into: Folder where to render carbon images.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL,
        style: CarbonStyle,
        filename: String,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, url: URL)> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.carbon(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, style: style, filename: filename, into: output)
    }
}

/// Instance of the Carbon API
public enum Carbon: CarbonAPI {
    public static func renderVerbose(
        content: String,
        style: CarbonStyle
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, images: NEA<Data>)> {
        
        NefCarbon.Carbon()
            .page(content: content)
            .contramap { progressReport in
                environment(progressReport: progressReport, style: style)
            }
            .mapError { _ in nef.Error.carbon() }
    }
    
    public static func renderVerbose(
        content: String,
        style: CarbonStyle,
        filename: String,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, (ast: String, url: URL)> {
        
        NefCarbon.Carbon()
            .page(content: content, filename: filename.removeExtension, into: output)
            .contramap { progressReport in environment(progressReport: progressReport, style: style) }
            .mapError { e in nef.Error.carbon(info: "\(e)") }
    }
    
    public static func render(
        playground: URL,
        style: CarbonStyle,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefCarbon.Carbon()
            .playground(playground, into: output)
            .contramap { progressReport in environment(progressReport: progressReport, style: style) }
            .mapError { _ in nef.Error.carbon() }
    }
    
    public static func render(
        playgroundsAt: URL,
        style: CarbonStyle,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefCarbon.Carbon()
            .playgrounds(at: playgroundsAt, into: output)
            .contramap { progressReport in environment(progressReport: progressReport, style: style) }
            .mapError { _ in nef.Error.carbon() }
    }
    
    public static func request(
        configuration: CarbonModel
    ) -> URLRequest {
        
        NefCarbon.Carbon()
            .request(configuration: configuration)
    }
    
    public static func view(
        configuration: CarbonModel
    ) -> NefModels.CarbonView {
        
        NefCarbon.Carbon()
            .view(configuration: configuration)
    }
    
    // MARK: - private <helpers>
    private static func environment(progressReport: ProgressReport, style: CarbonStyle) -> NefCarbon.Carbon.Environment {
        NefCarbon.Carbon.Environment(
            progressReport: progressReport,
            fileSystem: MacFileSystem(),
            persistence: RenderingPersistence(),
            xcodePlaygroundSystem: MacXcodePlaygroundSystem(),
            style: style,
            carbonPrinter: CoreRender.carbon.render)
    }
}
