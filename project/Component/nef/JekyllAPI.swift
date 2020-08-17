//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
@_exported import NefModels
import NefRender
import NefJekyll
import Bow
import BowEffects

/// Describes the API for `Jekyll`
public protocol JekyllAPI {
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String,
        permalink: String
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage>
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        content: String,
        permalink: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playground: Path to Xcode playground.
    ///   - into: Folder where to render the jekyll files (for each playground's page).
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll files generated of type `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playground: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
    
    /// Renders playground pages into jekyll files.
    ///
    /// - Parameters:
    ///   - playgroundsAt: Folder where to search Xcode Playgrounds (recursive search).
    ///   - mainPage: The main page path (in jekyll file format).
    ///   - into: Folder where to render the jekyll site.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the playgrounds path rendered `[URL]`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        playgroundsAt: URL,
        mainPage: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>>
}

public extension JekyllAPI {
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String,
        permalink: String
    ) -> EnvIO<ProgressReport, nef.Error, String> {
        
        renderVerbose(content: content, permalink: permalink)
            .map { info in info.rendered.content }^
    }
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the jekyll generated of type `String`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL,
        permalink: String
    ) -> EnvIO<ProgressReport, nef.Error, String> {
        
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.jekyll(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, permalink: permalink)
    }
    
    /// Renders content into jekyll format.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL,
        permalink: String
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.jekyll(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, permalink: permalink)
    }
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - content: Content page in Xcode playground.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        content: String,
        permalink: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        renderVerbose(content: content, permalink: permalink, toFile: file)
            .flatMap { info in
                guard case let .url(file) = info.rendered else {
                    return .raiseError(.jekyll(info: "invalid rendered content"))
                }
                
                return .pure(file)^
            }^
    }
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the file generated of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        page: URL,
        permalink: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.jekyll(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, permalink: permalink, toFile: file)
    }
    
    /// Renders content into jekyll file.
    ///
    /// - Parameters:
    ///   - page: Path to Xcode playground page.
    ///   - permalink: Relative url where locate the page.
    ///   - toFile: Output where to write the Markdown render.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the render information, having access to an immutable environment of type `ProgressReport`.
    static func renderVerbose(
        page: URL,
        permalink: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        guard let contentPage = page.contentPage,
            !contentPage.isEmpty else {
            return EnvIO.raiseError(.jekyll(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, permalink: permalink, toFile: file)
    }
}

/// Instance of the Jekyll API
public enum Jekyll: JekyllAPI {
    public static func renderVerbose(
        content: String,
        permalink: String
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        NefJekyll.Jekyll()
            .page(content: content, permalink: permalink)
            .contramap(environment)
            .mapError { e in nef.Error.jekyll(info: "\(e)") }
    }
    
    public static func renderVerbose(
        content: String,
        permalink: String,
        toFile file: URL
    ) -> EnvIO<ProgressReport, nef.Error, RenderedPage> {
        
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent

        return NefJekyll.Jekyll()
            .page(content: content, permalink: permalink, filename: filename, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.jekyll(info: "\(e)") }
    }
    
    
    public static func render(
        playground: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefJekyll.Jekyll()
            .playground(playground, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.jekyll(info: "\(e)") }^
    }
    
    public static func render(
        playgroundsAt: URL,
        mainPage: URL,
        into output: URL
    ) -> EnvIO<ProgressReport, nef.Error, NEA<URL>> {
        
        NefJekyll.Jekyll()
            .playgrounds(at: playgroundsAt, mainPage: mainPage, into: output)
            .contramap(environment)
            .mapError { e in nef.Error.jekyll(info: "\(e)") }^
    }
    
    // MARK: - private <helpers>
    private static func environment(
        progressReport: ProgressReport
    ) -> NefJekyll.Jekyll.Environment {
        
        NefJekyll.Jekyll.Environment(
            progressReport: progressReport,
            fileSystem: UnixFileSystem(),
            persistence: .init(),
            xcodePlaygroundSystem: UnixPlaygroundSystem(),
            jekyllPrinter: CoreRender.jekyll.render)
    }
}
