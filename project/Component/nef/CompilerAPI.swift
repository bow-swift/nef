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
    static func compile(playground: URL, cached: Bool) -> EnvIO<Console, nef.Error, Void> {
        NefCompiler.Compiler()
                   .playground(playground, cached: cached)
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
              compilerShell: MacCompilerShell(),
              playgroundSystem: MacPlaygroundSystem(),
              codePrinter: CoreRender.code.render)
    }
}
