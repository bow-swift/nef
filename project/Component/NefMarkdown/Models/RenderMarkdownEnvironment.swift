//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderMarkdownEnvironment<A> {
    public let fileSystem: FileSystem
    public let renderSystem: RenderSystem<A>
    public let renderEnvironment: RenderEnvironment<A>
    public let render: Render<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                renderSystem: RenderSystem<A>,
                playgroundSystem: PlaygroundSystem,
                nodePrinter: @escaping (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.renderSystem = renderSystem
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: nodePrinter)
        self.render = Render<A>()
    }
}
