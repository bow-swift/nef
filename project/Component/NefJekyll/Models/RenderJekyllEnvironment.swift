//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderJekyllEnvironment<A> {
    public let fileSystem: FileSystem
    public let renderSystem: RenderSystem<A>
    public let render: Render<A>
    public let renderEnvironment: (_ permalink: String) -> RenderEnvironment<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                renderSystem: RenderSystem<A>,
                playgroundSystem: PlaygroundSystem,
                jekyllPrinter: @escaping (_ permalink: String) -> RenderEnvironment<A>.NodePrinter) {
        
        self.fileSystem = fileSystem
        self.renderSystem = renderSystem
        self.render = Render<A>()
        self.renderEnvironment = { permalink in
            RenderEnvironment(console: console,
                              playgroundSystem: playgroundSystem,
                              nodePrinter: jekyllPrinter(permalink))
        }
    }
}
