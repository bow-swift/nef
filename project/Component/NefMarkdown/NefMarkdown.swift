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
        render.renderPage(content: content, generator: generator).map { rendered in
            (rendered: rendered.output, ast: rendered.ast)
        }^
    }
    
    public func renderPage(content: String, filename: String, into output: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        return render.renderPage(content: content, atFile: file, generator: generator)
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, filename: filename, generator: generator)
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlaygrounds(at: folder, into: output, filename: filename, generator: generator)
    }
    
    // MARK: private <helper>
    private var generator: CoreRender {
        MarkdownGenerator()
    }
    
    private func generator(playground: String, page: String) -> CoreRender {
        generator
    }
    
    private func filename(page: String) -> String {
        "\(page).md"
    }
}
