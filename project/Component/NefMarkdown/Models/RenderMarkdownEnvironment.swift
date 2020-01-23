//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderMarkdownEnvironment<A> {
    public let fileSystem: FileSystem
    public let persistence: RenderingPersistence<A>
    public let render: Render<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                persistence: RenderingPersistence<A>,
                playgroundSystem: PlaygroundSystem,
                markdownPrinter: @escaping (_ content: String) -> EnvIO<CoreMarkdownEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.persistence = persistence
        self.render = Render<A>()
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, nodePrinter: { content in markdownPrinter(content).provide(.init()).env() })
    }
}
