//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderCompilerEnvironment<A> {
    public let compilerSystem: CompilerSystem
    public let render: Render<A>
    public let codeEnvironment: RenderEnvironment<A>
    
    internal var console: Console { codeEnvironment.console }
    
    public init(console: Console,
                compilerSystem: CompilerSystem,
                playgroundSystem: PlaygroundSystem,
                codePrinter: @escaping (_ content: String) -> EnvIO<CoreCodeEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.compilerSystem = compilerSystem
        self.render = Render<A>()
        self.codeEnvironment = RenderEnvironment(console: console,
                                                 playgroundSystem: playgroundSystem,
                                                 nodePrinter: { content in codePrinter(content).provide(.init()).env() })
    }
}
