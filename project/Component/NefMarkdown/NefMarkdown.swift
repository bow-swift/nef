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
    typealias PageOutput  = RenderingOutput<String>.PageOutput
    typealias PlaygroundOutput  = RenderingOutput<String>.PlaygroundOutput
    typealias PlaygroundsOutput = RenderingOutput<String>.PlaygroundsOutput
    
    public init() {}
    
    public func page(content: String) -> EnvIO<MarkdownEnvironment, RenderError, (ast: String, rendered: String)> {
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
            rendered <- env.get.render.renderPage(content: content).contramap(\MarkdownEnvironment.renderEnvironment),
        yield: (rendered: rendered.get.output.all().joined(), ast: rendered.get.ast))^
    }

    public func page(content: String, filename: String, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let content = EnvIO<MarkdownEnvironment, RenderError, String>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
             content <- env.get.fileSystem.readFile(atPath: file.path).mapLeft { _ in .renderPage(file) }.env(),
            rendered <- env.get.render.renderPage(content: content.get).contramap(\MarkdownEnvironment.renderEnvironment),
                     |<-env.get.renderSystem.writePage(rendered.get, file).contramap(\MarkdownEnvironment.fileSystem).mapError { _ in .renderPage(file) },
        yield: (url: file, ast: rendered.get.ast, rendered: rendered.get.output.all().joined()))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.renderPlayground(playground).contramap(\MarkdownEnvironment.renderEnvironment),
              written <- rendered.get.traverse(self.writtenPage),
        yield: written.get)^
    }
    
    public func playgrounds(atFolder folder: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.renderPlaygrounds(at: folder).contramap(\MarkdownEnvironment.renderEnvironment),
              written <- rendered.get.traverse(self.writtenPlayground),
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func writtenPage(page: RenderingURL, output: PageOutput) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        EnvIO { env in
            let file = page.url.appendingPathExtension("md")
            return env.renderSystem.writePage(output, file).provide(env.fileSystem)
                                   .map { _ in file }^.mapLeft { _ in .renderPage(file) }
        }^
    }
    
    private func writtenPlayground(playground: RenderingURL, output: PlaygroundOutput) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        output.traverse(self.writtenPage).map { _ in playground.url }^
    }
}
