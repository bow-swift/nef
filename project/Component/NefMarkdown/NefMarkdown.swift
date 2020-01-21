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
            rendered <- env.get.render.page(content: content).contramap(\MarkdownEnvironment.renderEnvironment),
        yield: (rendered: self.contentFrom(page: rendered.get), ast: rendered.get.ast))^
    }

    public func page(content: String, filename: String, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let content = EnvIO<MarkdownEnvironment, RenderError, String>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
             content <- env.get.fileSystem.readFile(atPath: file.path).mapLeft { _ in .renderPage(file) }.env(),
            rendered <- env.get.render.page(content: content.get).contramap(\MarkdownEnvironment.renderEnvironment),
                     |<-env.get.renderSystem.writePage(rendered.get, file).contramap(\MarkdownEnvironment.fileSystem).mapError { _ in .renderPage(file) },
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playground(playground).contramap(\MarkdownEnvironment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) },
        yield: written.get)^
    }
    
    public func playgrounds(atFolder folder: URL, into output: URL) -> EnvIO<MarkdownEnvironment, RenderError, NEA<URL>> {
        let env = EnvIO<MarkdownEnvironment, RenderError, MarkdownEnvironment>.var()
        let rendered = EnvIO<MarkdownEnvironment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<MarkdownEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playgrounds(at: folder).contramap(\MarkdownEnvironment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPlayground(playground: info.playground, content: info.output, output: output) },
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func writtenPage(page: RenderingURL, content: PageOutput, output: URL) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(page.escapedTitle).appendingPathExtension("md")
            return env.renderSystem.writePage(content, file).provide(env.fileSystem)
                                   .map { _ in file }^.mapLeft { _ in .renderPage(file) }
        }^
    }
    
    private func writtenPlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<MarkdownEnvironment, RenderError, URL> {
        content.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    private func contentFrom(page: PageOutput) -> String {
        page.output.all().joined()
    }
}
