//  Copyright © 2019 The nef Authors.

import NefModels
import NefCommon
import NefCore
import BowOptics

public struct RenderEnvironment: AutoOptics {
    public var console: Console
    public var playgroundSystem: PlaygroundSystem
    public var fileSystem: RenderSystem
    public var nodePrinter: (RendererPage) -> CoreRender
    
    public init(console: Console, playgroundSystem: PlaygroundSystem, fileSystem: RenderSystem, nodePrinter: @escaping (RendererPage) -> CoreRender) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.fileSystem = fileSystem
        self.nodePrinter = nodePrinter
    }
}
