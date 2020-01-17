//  Copyright © 2019 The nef Authors.

import NefModels
import NefCommon
import NefCore
import BowOptics

public struct RenderEnvironment: AutoOptics {
    public var console: Console
    public var playgroundSystem: PlaygroundSystem
    public var fileSystem: FileSystem
    public var nodePrinter: (RendererPage) -> CoreRender
    
    public init(console: Console, playgroundSystem: PlaygroundSystem, fileSystem: FileSystem, nodePrinter: @escaping (RendererPage) -> CoreRender) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.fileSystem = fileSystem
        self.nodePrinter = nodePrinter
    }
}
