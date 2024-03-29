//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
@_exported import NefModels
import NefRender
import NefMarkdown
import Bow
import BowEffects

/// Describes the API for `Markdown`
public protocol MarkdownAPI {
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage>
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - into: Folder where to write the markdown files.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playground: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into markdown files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - into: Folder where to write the markdown files for each Xcode Playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playgroundsAt: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
}

public extension MarkdownAPI {
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String
    ) -> EnvIO<ProgressReport, nef.Error, String> {
        renderVerbose(content: content).map { info in info.rendered.content }^
    }
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the markdown generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL
    ) -> EnvIO<ProgressReport, nef.Error, String> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
            
        return render(content: contentPage)
    }
    
    /// Renders content into markdown.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage)
    }
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        renderVerbose(content: content, toFile: file)
            .flatMap { info in
                guard case let .url(file) = info.rendered else {
                    return .raiseError(.markdown(info: "invalid rendered content"))
                }
                
                return .pure(file)^
            }^
    }
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, toFile: file)
    }
    
    /// Renders content into markdown file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, toFile: file)
    }
}

/// Instance of the Markdown API
public enum Markdown: MarkdownAPI {
    
    public static func renderVerbose(
        content: String
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        NefMarkdown.Markdown()
            .page(content: content)
            .contramap(environment)
            .mapError { e in nef.Error.markdown(info: "\(e)") }
    }
    
    public static func renderVerbose(
        content: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent
        
        return NefMarkdown.Markdown()
            .page(content: content, filename: filename, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.markdown(info: "\(e)") }^
    }
    
    public static func render(
        playground: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefMarkdown.Markdown()
            .playground(playground, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.markdown(info: "\(e)") }^
    }
    
    public static func render(
        playgroundsAt folder: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefMarkdown.Markdown()
            .playgrounds(atFolder: folder, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.markdown(info: "\(e)") }^
    }
    
    // MARK: - private <helpers>
    private static func environment(
        progressReport: ProgressReport
    ) -> NefMarkdown.Markdown.Environment {
        
        NefMarkdown.Markdown.Environment(
            progressReport: progressReport,
            fileSystem: UnixFileSystem(),
            persistence: .init(),
            xcodePlaygroundSystem: UnixPlaygroundSystem(),
            markdownPrinter: CoreRender.markdown.render)
    }
}
