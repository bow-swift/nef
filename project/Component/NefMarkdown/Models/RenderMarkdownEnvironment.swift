//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct RenderMarkdownEnvironment<A> {
    public let console: Console
    public let fileSystem: FileSystem
    public let renderSystem: RenderSystem<A>
    public let renderEnvironment: RenderEnvironment<A>
    public let render: Render<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                renderSystem: RenderSystem<A>,
                playgroundSystem: PlaygroundSystem,
                nodePrinter: @escaping (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>) {
        
        self.console = console
        self.fileSystem = fileSystem
        self.renderSystem = renderSystem
        self.renderEnvironment = RenderEnvironment(playgroundSystem: playgroundSystem, nodePrinter: nodePrinter)
        self.render = Render<A>()
    }
}
