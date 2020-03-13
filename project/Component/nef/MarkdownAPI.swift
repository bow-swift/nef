//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import NefRender
import NefMarkdown

import Bow
import BowEffects

public extension MarkdownAPI {

    static func render(content: String) -> EnvIO<Console, nef.Error, String> {
        renderVerbose(content: content).map { info in info.rendered }^
    }
    
    static func render(page: URL) -> EnvIO<Console, nef.Error, String> {
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
            
        return render(content: contentPage)
    }
    
    static func renderVerbose(content: String) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)> {
        NefMarkdown.Markdown()
                   .page(content: content)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown() }
    }
    
    static func renderVerbose(page: URL) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)> {
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage)
    }
    
    static func render(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, toFile: file).map { info in info.url }^
    }
    
    static func render(page: URL, toFile output: URL) -> EnvIO<Console, nef.Error, URL> {
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return render(content: contentPage, toFile: output)
    }
    
    static func renderVerbose(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent
        
        return NefMarkdown.Markdown()
                          .page(content: content, filename: filename, into: output)
                          .contramap(environment)
                          .mapError { e in nef.Error.markdown(info: "\(e)") }^
    }
    
    static func renderVerbose(page: URL, toFile output: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)> {
        guard let contentPage = page.contentPage, !contentPage.isEmpty else {
            return EnvIO.raiseError(.markdown(info: "Error: could not read playground's page content (\(page.pageName))"))^
        }
        
        return renderVerbose(content: contentPage, toFile: output)
    }
    
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefMarkdown.Markdown()
                   .playground(playground, into: output)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown() }^
    }
    
    static func render(playgroundsAt folder: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefMarkdown.Markdown()
                   .playgrounds(atFolder: folder, into: output)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown() }^
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> NefMarkdown.Markdown.Environment {
        .init(console: console,
              fileSystem: MacFileSystem(),
              persistence: .init(),
              xcodePlaygroundSystem: MacXcodePlaygroundSystem(),
              markdownPrinter: CoreRender.markdown.render)
    }
}
