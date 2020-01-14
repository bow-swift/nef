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
        render.renderPage(content: content, generator: generator(permalink: permalink)).map { rendered in
            (rendered: rendered.output, ast: rendered.ast)
        }^
    }
    
    public func renderPage(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        return render.renderPage(content: content, atFile: file, generator: generator(permalink: permalink))
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, filename: filename, generator: generator)
    }
    
    public func renderPlaygrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let rendered = EnvIO<RenderEnvironment, RenderError, [URL]>.var()
        
        return binding(
            rendered <- self.render.renderPlaygrounds(at: folder, into: output, filename: self.filename, generator: self.generator),
        yield: rendered.get)^
    }
    
    // MARK: - generator <helpers>
    private func generator(playground: String, page: String) -> CoreRender {
        generator(permalink: "/docs/\(playground)/\(page)")
    }
    
    private func generator(permalink: String) -> CoreRender {
        JekyllGenerator(permalink: permalink)
    }
    
    private func filename(page: String) -> String {
        "\(page)/README.md"
    }
    
    // MARK: - private <helpers>
    private func buildMainPage(_ mainPage: URL) {
        fatalError()
    }
    
    private func buildSideBar(_ playgrounds: [URL]) {
        fatalError()
    }
}
