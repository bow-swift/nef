//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderJekyllEnvironment<A> {
    public let fileSystem: FileSystem
    public let persistence: RenderingPersistence<A>
    public let render: Render<A>
    public let jekyllEnvironment: (_ permalink: String) -> RenderEnvironment<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    internal var console: Console { renderEnvironment.console }
    
    public init(console: Console,
                fileSystem: FileSystem,
                persistence: RenderingPersistence<A>,
                playgroundSystem: PlaygroundSystem,
                jekyllPrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.persistence = persistence
        self.render = Render<A>()
        self.jekyllEnvironment = { permalink in RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: Self.nodePrinter(from: jekyllPrinter, permalink: permalink)) }
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: Self.nodePrinter(from: jekyllPrinter))
    }
    
    // MARK: - helpers
    static var docs: String { "docs" }
    static var data: String { "_data" }
    
    static func permalink(info: RenderEnvironmentInfo) -> IO<CoreRenderError, String> {
        switch info {
        case let .info(playground, page):
            return IO.pure("/\(docs)/\(playground.escapedTitle)/\(page.escapedTitle)/")^
        default:
            return IO.raiseError(.renderEmpty)^
        }
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
            EnvIO<RenderEnvironmentInfo, CoreRenderError, RenderingOutput<A>> { info in
                permalink(info: info).flatMap { permalink -> IO<CoreRenderError, RenderingOutput<A>> in
                    nodePrinter(content).provide(.init(permalink: permalink))^
                }
            }
        }
    }
}
