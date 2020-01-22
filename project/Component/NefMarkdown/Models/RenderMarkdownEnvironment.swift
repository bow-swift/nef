//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderMarkdownEnvironment<A> {
    public let fileSystem: FileSystem
    public let renderSystem: RenderSystem<A>
    public let render: Render<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                renderSystem: RenderSystem<A>,
                playgroundSystem: PlaygroundSystem,
                markdownPrinter: @escaping (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.renderSystem = renderSystem
        self.render = Render<A>()
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: { content in markdownPrinter(content).env() })
    }
}
