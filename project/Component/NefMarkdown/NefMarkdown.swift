//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Markdown {
    private let generator = MarkdownGenerator()
    private let render = NefRender()
    
    public init() {}
    
    public func renderPage(content: String) -> EnvIO<RenderEnvironment, RenderError, (rendered: String, ast: String)> {
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<RenderError, RendererOutput>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering markdown content"),
                rendered <- self.render.renderPage(content: content, generator: self.generator).provide(env),
            yield:(rendered: rendered.get.output, ast: rendered.get.ast))^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPage(content: String, filename: String, into output: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<RenderError, (url: URL, ast: String, trace: String)>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering markdown '\(filename)'"),
                rendered <- self.render.renderPage(content: content, atFile: file, generator: self.generator).provide(env),
            yield: rendered.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgroundName = playground.path.filename.removeExtension
        let output = output.appendingPathComponent(playgroundName)
        
        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var([URL].self)
        
        return binding(
              pages <- self.render.getPages(step: step.increment(1), playground: playground),
                    |<-self.render.structure(step: step.increment(2), output: output),
           rendered <- self.render.renderPages(pages: pages.get, output: output, generator: self.generator),
        yield: rendered.get)^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var([URL].self)
        
        return binding(
                        |<-self.render.structure(step: step.increment(1), output: output),
            playgrounds <- self.render.getPlaygrounds(step: step.increment(2), at: folder),
                  pages <- playgrounds.get.all().flatTraverse { playground in self.renderPlayground(playground, into: output) }^,
        yield: playgrounds.get.all())^
    }
}
