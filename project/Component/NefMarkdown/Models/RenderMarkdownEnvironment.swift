//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderMarkdownEnvironment<A> {
    public let persistence: RenderingPersistence<A>
    public let render: Render<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    internal var fileSystem: FileSystem { renderEnvironment.fileSystem }
    
    public init(console: Console,
                fileSystem: FileSystem,
                persistence: RenderingPersistence<A>,
                xcodePlaygroundSystem: XcodePlaygroundSystem,
                markdownPrinter: @escaping (_ content: String) -> EnvIO<CoreMarkdownEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.persistence = persistence
        self.render = Render<A>()
        self.renderEnvironment = RenderEnvironment(console: console, fileSystem: fileSystem, xcodePlaygroundSystem: xcodePlaygroundSystem, nodePrinter: { content in markdownPrinter(content).provide(.init()).env() })
    }
}
