//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

public struct RenderMarkdownEnvironment {
    public let renderEnvironment: RenderEnvironment
    
    
    public init(console: Console,
                playgroundSystem: PlaygroundSystem,
                fileSystem: RenderSystem,
                nodePrinter: @escaping (RendererPage) -> CoreRender) {
        
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, fileSystem: fileSystem, nodePrinter: nodePrinter)
    }
}
