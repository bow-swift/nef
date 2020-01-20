//  Copyright © 2019 The nef Authors.

import NefCommon
import NefCore
import BowEffects

public struct RenderEnvironment<A> {
    public let playgroundSystem: PlaygroundSystem
    public let nodePrinter: (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>

    public init(playgroundSystem: PlaygroundSystem, nodePrinter: @escaping (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>) {
        self.playgroundSystem = playgroundSystem
        self.nodePrinter = nodePrinter
    }
}
