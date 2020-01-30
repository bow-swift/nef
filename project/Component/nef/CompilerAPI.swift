//  Copyright © 2020 The nef Authors.

import Foundation
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
            .mapError { _ in nef.Error.compiler }
//        NefCompiler.Compiler()
//                   .page(content: content)
//                   .contramap(environment)
//                   .mapError { _ in nef.Error.compiler }
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> NefCompiler.Compiler.Environment {
        .init(console: console,
              fileSystem: MacFileSystem(),
              compilerShell: MacCompilerShell(),
              compilerSystem: MacCompilerSystem(),
              playgroundSystem: MacPlaygroundSystem(),
              codePrinter: CoreRender.code.render)
    }
}
