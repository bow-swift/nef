//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderCompilerEnvironment<A> {
    let fileSystem: FileSystem
    let compilerShell: CompilerShell
    let compilerSystem: CompilerSystem
    let render: Render<A>
    let codeEnvironment: RenderEnvironment<A>
    
    internal var console: Console { codeEnvironment.console }
    internal var playgroundSystem: PlaygroundSystem { codeEnvironment.playgroundSystem }
    internal var compilerEnvironment: CompilerSystemEnvironment { .init(fileSystem: self.fileSystem, shell: self.compilerShell) }
    
    public init(console: Console,
                fileSystem: FileSystem,
                compilerShell: CompilerShell,
                compilerSystem: CompilerSystem,
                playgroundSystem: PlaygroundSystem,
                codePrinter: @escaping (_ content: String) -> EnvIO<CoreCodeEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.fileSystem = fileSystem
        self.compilerShell = compilerShell
        self.compilerSystem = compilerSystem
        self.render = Render<A>()
        self.codeEnvironment = RenderEnvironment(console: console,
                                                 playgroundSystem: playgroundSystem,
                                                 nodePrinter: { content in codePrinter(content).provide(.init()).env() })
    }
}
