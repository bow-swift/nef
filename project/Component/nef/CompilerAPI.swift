//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCore
import NefModels
import NefRender
import NefCompiler

import Bow
import BowEffects

public extension CompilerAPI {
    static func compile(content: String) -> EnvIO<Console, nef.Error, Void> {
        NefCompiler.Compiler()
            .playgrounds(atFolder: URL(fileURLWithPath: "/Users/miguelangel/Desktop/BowPlayground.app"), cached: false)
            .contramap(environment)
            .mapError { e in nef.Error.compiler(info: "\(e)") }
    }
    
    static func compile(playgroundsAt: URL, cached: Bool) -> EnvIO<Console, nef.Error, Void> {
        NefCompiler.Compiler()
                   .playgrounds(atFolder: playgroundsAt, cached: cached)
                   .contramap(environment)
                   .mapError { e in nef.Error.compiler(info: "\(e)") }
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> NefCompiler.Compiler.Environment {
        .init(console: console,
              fileSystem: MacFileSystem(),
              compilerShell: MacCompilerShell(),//DummyCompilerShell(),//MacCompilerShell(),
              compilerSystem: MacCompilerSystem(),
              playgroundSystem: MacPlaygroundSystem(),
              codePrinter: CoreRender.code.render)
    }
}

class DummyCompilerShell: CompilerShell {
    let macShell = MacCompilerShell()
    
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> { IO.pure(())^ }
    func carthage(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> { IO.pure(())^ }
    
    func build(xcworkspace: URL, scheme: String, platform: Platform, derivedData: URL, log: URL) -> IO<CompilerShellError, Void> {
        macShell.build(xcworkspace: xcworkspace, scheme: scheme, platform: platform, derivedData: derivedData, log: URL.init(fileURLWithPath: "/tmp/dummy-build.log"))
    }
}
