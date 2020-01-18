//  Copyright © 2019 The nef Authors.

import NefUtils
import NefCore
import BowEffects
import BowOptics

public struct RenderEnvironment<A>: AutoOptics {
    public var playgroundSystem: PlaygroundSystem
    public var nodePrinter: (_ content: String) -> IO<CoreRenderError, RendererOutput<A>>
    
    public init(playgroundSystem: PlaygroundSystem, nodePrinter: @escaping (_ content: String) -> IO<CoreRenderError, RendererOutput<A>>) {
        self.playgroundSystem = playgroundSystem
        self.nodePrinter = nodePrinter
    }
}
