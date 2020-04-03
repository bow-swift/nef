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
    
    internal var progressReport: ProgressReport { codeEnvironment.progressReport }
    internal var fileSystem: FileSystem { codeEnvironment.fileSystem }
    internal var xcodePlaygroundSystem: XcodePlaygroundSystem { codeEnvironment.xcodePlaygroundSystem }
    
    public init(
        progressReport: ProgressReport,
        fileSystem: FileSystem,
        compilerShell: CompilerShell,
        nefPlaygroundSystem: NefPlaygroundSystem,
        xcodePlaygroundSystem: XcodePlaygroundSystem,
        codePrinter: @escaping (_ content: String) -> EnvIO<CoreCodeEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.compilerSystem = NefCompilerSystem()
        self.compilerEnvironment = CompilerSystemEnvironment(
            shell: compilerShell,
            fileSystem: fileSystem,
            nefPlaygroundSystem: nefPlaygroundSystem)
        
        self.render = Render<A>()
        self.codeEnvironment = RenderEnvironment(
            progressReport: progressReport,
            fileSystem: fileSystem,
            xcodePlaygroundSystem: xcodePlaygroundSystem,
            nodePrinter: { content in codePrinter(content).provide(.init()).env() })
    }
}
