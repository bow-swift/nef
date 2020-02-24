//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCore
import NefModels
import NefRender
import NefCompiler
import NefPlayground

import Bow
import BowEffects

public extension CompilerAPI {
    
    static func compile(xcodePlayground: URL, platform: Platform, dependencies: PlaygroundDependencies, cached: Bool) -> EnvIO<Console, nef.Error, Void> {
        let playgroundName = xcodePlayground.lastPathComponent.removeExtension
        let output = URL(fileURLWithPath: "/tmp/\(playgroundName)")
        let nefPlayground = EnvIO<Console, nef.Error, URL>.var()
        
        return binding(
            nefPlayground <- Playground.nef(xcodePlayground: xcodePlayground, name: playgroundName, output: output, platform: platform, dependencies: dependencies),
                          |<-compile(nefPlayground: nefPlayground.get, cached: cached),
        yield: ())^
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
              playgroundShell: MacPlaygroundShell(),
              playgroundSystem: MacXcodePlaygroundSystem(),
              codePrinter: CoreRender.code.render)
    }
}
