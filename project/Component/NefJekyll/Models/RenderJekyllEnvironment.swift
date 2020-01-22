//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderJekyllEnvironment<A> {
    public let fileSystem: FileSystem
    public let renderSystem: RenderSystem<A>
    public let render: Render<A>
    public let jekyllEnvironment: (_ permalink: String) -> RenderEnvironment<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    internal var console: Console { renderEnvironment.console }
    
    public init(console: Console,
                fileSystem: FileSystem,
                renderSystem: RenderSystem<A>,
                playgroundSystem: PlaygroundSystem,
                jekyllPrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.renderSystem = renderSystem
        self.render = Render<A>()
        self.jekyllEnvironment = { permalink in RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: Self.nodePrinter(from: jekyllPrinter, permalink: permalink)) }
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: Self.nodePrinter(from: jekyllPrinter))
    }
    
    // MARK: - helpers
    static var docs: String { "docs" }
    
    static func permalink(playground: RenderingURL, page: RenderingURL) -> String {
        "/\(docs)/\(playground.escapedTitle)/\(page.escapedTitle)/"
    }
    
    // MARK: - init <helper>
    private static func nodePrinter(from nodePrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>,
                                    permalink: String) -> RenderEnvironment<A>.NodePrinter {
        { content in
            nodePrinter(content).provide(.init(permalink: permalink)).env()
        }
    }
    
    private static func nodePrinter(from nodePrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>) -> RenderEnvironment<A>.NodePrinter {
        { content in
            EnvIO { info in
                nodePrinter(content).provide(.init(permalink: permalink(playground: info.playground, page: info.page)))
            }
        }
    }
}
