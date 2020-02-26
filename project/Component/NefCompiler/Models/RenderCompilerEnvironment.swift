//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderCompilerEnvironment<A> {
    let compilerSystem: CompilerSystem
    let compilerEnvironment: CompilerSystemEnvironment
    let render: Render<A>
    let codeEnvironment: RenderEnvironment<A>
    
    internal var console: Console { codeEnvironment.console }
    internal var playgroundSystem: PlaygroundSystem { codeEnvironment.playgroundSystem }
    internal var fileSystem: FileSystem { codeEnvironment.fileSystem }
    
    public init(console: Console,
                fileSystem: FileSystem,
                compilerShell: CompilerShell,
                playgroundSystem: PlaygroundSystem,
                codePrinter: @escaping (_ content: String) -> EnvIO<CoreCodeEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.compilerSystem = NefCompilerSystem()
        self.compilerEnvironment = CompilerSystemEnvironment(fileSystem: fileSystem, shell: compilerShell)
        
        self.render = Render<A>()
        self.codeEnvironment = RenderEnvironment(console: console,
                                                 playgroundSystem: playgroundSystem,
                                                 fileSystem: fileSystem,
                                                 nodePrinter: { content in codePrinter(content).provide(.init()).env() })
    }
}
