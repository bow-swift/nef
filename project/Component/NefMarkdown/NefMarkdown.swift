//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Markdown {
    public typealias MarkdownEnvironment = RenderMarkdownEnvironment<String>
    typealias RenderingOutput = NefCommon.RenderingOutput<String>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<String>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<String>
    
    public init() {}
    
    public func page(content: String) -> EnvIO<MarkdownEnvironment, RenderError, (ast: String, rendered: String)> {
        renderPage(content: content).map { rendered in
            (ast: rendered.ast, rendered: self.contentFrom(page: rendered))
        }^
    }

    public func page(content: String, filename: String, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        let content = EnvIO<MarkdownEnvironment, RenderError, String>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, RenderingOutput>.var()
        
        return binding(
             content <- self.read(file: file).contramap(\MarkdownEnvironment.fileSystem),
            rendered <- self.renderPage(content: content.get),
                     |<-self.writePage(rendered.get, atFile: file),
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlayground(playground),
              written <- self.writePages(rendered.get, into: output),
        yield: written.get)^
    }
    
    public func playgrounds(atFolder folder: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlaygrounds(atFolder: folder),
              written <- self.writePlaygrounds(rendered.get, into: output),
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func writePages(_ pages: PlaygroundOutput, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        pages.traverse { info in self.writePage(page: info.page, content: info.output, output: output)^ }^
    }
    
    private func writePage(page: RenderingURL, content: RenderingOutput, output: URL) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(page.escapedTitle).appendingPathExtension("md")
            return env.persistence.writePage(content, file).provide(env.fileSystem)
                                  .map { _ in file }^.mapLeft { _ in .page(file) }
        }^
    }
    
    private func writePlaygrounds(_ playgrounds: PlaygroundsOutput, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        playgrounds.traverse { info in self.writePlayground(playground: info.playground, content: info.output, output: output)^ }^
    }
    
    private func writePlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        content.traverse { info in self.writePage(page: info.page, content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    func read(file: URL) -> EnvIO<FileSystem, RenderError, String> {
        EnvIO { fileSystem in
            fileSystem.readFile(atPath: file.path).mapLeft { _ in .page(file) }
        }
    }
    
    func renderPage(content: String) -> EnvIO<MarkdownEnvironment, RenderError, RenderingOutput> {
        EnvIO { env in env.render.page(content: content).provide(env.renderEnvironment) }
    }
    
    func renderPlayground(_ playground: URL) -> EnvIO<MarkdownEnvironment, RenderError, PlaygroundOutput> {
        EnvIO { env in env.render.playground(playground).provide(env.renderEnvironment) }
    }
    
    func renderPlaygrounds(atFolder folder: URL) -> EnvIO<MarkdownEnvironment, RenderError, PlaygroundsOutput> {
        EnvIO { env in env.render.playgrounds(at: folder).provide(env.renderEnvironment) }
    }
    
    func writePage(_ page: RenderingOutput, atFile file: URL) -> EnvIO<MarkdownEnvironment, RenderError, Void> {
        EnvIO { env in
            env.persistence.writePage(page, file).provide(env.fileSystem).mapLeft { _ in .page(file) }
        }
    }
    
    private func contentFrom(page: RenderingOutput) -> String {
        page.output.all().joined()
    }
}
