//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import NefRender
import NefMarkdown

import Bow
import BowEffects

public extension MarkdownAPI {
    
    // MARK: api <EnvIO>
    static func render(content: String) -> EnvIO<Console, nef.Error, String> {
        renderVerbose(content: content).map { info in info.rendered }^
    }
    
    static func renderVerbose(content: String) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)> {
        NefMarkdown.Markdown()
                   .page(content: content)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown }
    }
    
    static func render(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, toFile: file).map { info in info.url }^
    }
    
    static func renderVerbose(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent
        
        return NefMarkdown.Markdown()
                          .page(content: content, filename: filename, into: output)
                          .contramap(environment)
                          .mapError { e in nef.Error.markdown }^
    }
    
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefMarkdown.Markdown()
                   .playground(playground, into: output)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown }^
    }
    
    static func render(playgroundsAt folder: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefMarkdown.Markdown()
                   .playgrounds(atFolder: folder, into: output)
                   .contramap(environment)
                   .mapError { _ in nef.Error.markdown }^
    }
    
    // MARK: api <IO>
    static func renderIO(content: String) -> IO<nef.Error, String> {
        render(content: content).provide(MacDummyConsole())
    }
    
    static func renderVerboseIO(content: String) -> IO<nef.Error, (ast: String, rendered: String)> {
        renderVerbose(content: content).provide(MacDummyConsole())
    }
    
    static func renderIO(content: String, toFile file: URL) -> IO<nef.Error, URL> {
        render(content: content, toFile: file).provide(MacDummyConsole())
    }
    
    static func renderVerboseIO(content: String, toFile file: URL) -> IO<nef.Error, (url: URL, ast: String, rendered: String)> {
        renderVerbose(content: content, toFile: file).provide(MacDummyConsole())
    }
    
    static func renderIO(playground: URL, into output: URL) -> IO<nef.Error, NEA<URL>> {
        render(playground: playground, into: output).provide(MacDummyConsole())
    }
    
    static func renderIO(playgroundsAt folder: URL, into output: URL) -> IO<nef.Error, NEA<URL>> {
        render(playgroundsAt: folder, into: output).provide(MacDummyConsole())
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> RenderMarkdownEnvironment<String> {
        .init(console: console,
              fileSystem: MacFileSystem(),
              renderSystem: .init(),
              playgroundSystem: MacPlaygroundSystem(),
              markdownPrinter: { content in CoreRender.markdown.render(content: content).provide(.init()) })
    }
}
