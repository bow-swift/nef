//  Copyright © 2020 The nef Authors.

import Foundation
import NefUtils
import NefModels
import NefCore
import NefRender

public struct RenderMarkdownEnvironment {
    public let renderEnvironment: RenderEnvironment
    
    
    public init(console: Console,
                playgroundSystem: PlaygroundSystem,
                fileSystem: FileSystem,
                nodePrinter: @escaping (RendererPage) -> CoreRender) {
        
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, fileSystem: fileSystem, nodePrinter: nodePrinter)
    }
}
