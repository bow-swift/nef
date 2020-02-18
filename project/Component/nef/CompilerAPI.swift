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
    static func compile(playground: URL, platform: Platform, dependencies: PlaygroundDependencies, cached: Bool) -> EnvIO<Console, nef.Error, Void> {
        #warning("it will be completed after nef-playground refactor")
        fatalError()
    }
        
    static func compile(nefPlayground: URL, cached: Bool) -> EnvIO<Console, nef.Error, Void> {
        NefCompiler.Compiler()
                   .nefPlayground(.init(project: nefPlayground), cached: cached)
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
