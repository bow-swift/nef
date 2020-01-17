//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Markdown {
    private let render = Render()
    
    public init() {}
    
    public func renderPage(content: String) -> EnvIO<RenderMarkdownEnvironment, RenderError, (rendered: String, ast: String)> {
        render.renderPage(content: content).contramap(\RenderMarkdownEnvironment.renderEnvironment).map { rendered in
            (rendered: rendered.output, ast: rendered.ast)
        }^
    }
    
    public func renderPage(content: String, filename: String, into output: URL) -> EnvIO<RenderMarkdownEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        return render.renderPage(content: content, atFile: file).contramap(\RenderMarkdownEnvironment.renderEnvironment)
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderMarkdownEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, filename: filename).contramap(\RenderMarkdownEnvironment.renderEnvironment).map { rendered in
            rendered.pages.all().map { page in page.url }
        }^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL) -> EnvIO<RenderMarkdownEnvironment, RenderError, [URL]> {
        render.renderPlaygrounds(at: folder, into: output, filename: filename).contramap(\RenderMarkdownEnvironment.renderEnvironment).map { rendered in
            rendered.playgrounds.all().map { info in info.playground.url }
        }^
    }
    
    // MARK: private <helper>
    private func filename(_ info: RendererPage) -> String {
        "\(info.page.escapedTitle).md"
    }
}
