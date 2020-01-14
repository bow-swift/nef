//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    private let render = NefRender()
    
    public init() {}
    
    public func renderPage(content: String, permalink: String) -> EnvIO<RenderEnvironment, RenderError, (rendered: String, ast: String)> {
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<RenderError, RendererOutput>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering jekyll content"),
                rendered <- self.render.renderPage(content: content, generator: self.generator(permalink: permalink)).provide(env),
            yield:(rendered: rendered.get.output, ast: rendered.get.ast))^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPage(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<RenderError, (url: URL, ast: String, trace: String)>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering jekyll '\(filename)'"),
                rendered <- self.render.renderPage(content: content, atFile: file, generator: self.generator(permalink: permalink)).provide(env),
            yield: rendered.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, generator: generator)
    }
    
    public func renderPlaygrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let rendered = IO<RenderError, [URL]>.var()
        
        return EnvIO { env in
            binding(
                rendered <- self.render.renderPlaygrounds(at: folder, into: output, generator: self.generator).provide(env),
            yield: rendered.get)^
        }
    }
    
    // MARK: - generator <helpers>
    private func generator(playground: URL, page: URL) -> CoreRender {
        let permalink = "/docs/\(playground.lastPathComponent)/\(page.lastPathComponent)"
        return generator(permalink: permalink)
    }
    
    private func generator(permalink: String) -> CoreRender {
        JekyllGenerator(permalink: permalink)
    }
    
    // MARK: - private <helpers>
    private func buildMainPage(_ mainPage: URL) {
        fatalError()
    }
    
    private func buildSideBar(_ playgrounds: [URL]) {
        fatalError()
    }
}
