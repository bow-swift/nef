//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Markdown {
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
        render.renderPlayground(playground, into: output, generator: generator)
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlaygrounds(at: folder, into: output, generator: generator)
    }
    
    // MARK: private <helper>
    private var generator: CoreRender {
        MarkdownGenerator()
    }
    
    private func generator(playground: URL, page: URL) -> CoreRender {
        generator
    }
}
