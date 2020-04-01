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
    
    static func compile(xcodePlayground: URL, platform: Platform, dependencies: PlaygroundDependencies, cached: Bool) -> EnvIO<ProgressReport, nef.Error, Void> {
        let playgroundName = xcodePlayground.lastPathComponent.removeExtension
        let output = URL(fileURLWithPath: "/tmp/\(playgroundName)")
        let nefPlayground = EnvIO<ProgressReport, nef.Error, URL>.var()
        
        return binding(
            nefPlayground <- Playground.nef(
                xcodePlayground: xcodePlayground,
                name: playgroundName,
                output: output,
                platform: platform,
                dependencies: dependencies),
            
            |<-compile(nefPlayground: nefPlayground.get, cached: cached),
        yield: ())^
    }
        
    static func compile(nefPlayground: URL, cached: Bool) -> EnvIO<ProgressReport, nef.Error, Void> {
        NefCompiler.Compiler()
                   .nefPlayground(.init(project: nefPlayground), cached: cached)
                   .contramap(environment)
                   .mapError { e in nef.Error.compiler(info: "\(e)") }
    }
    
    // MARK: - private <helpers>
    private static func environment(progressReport: ProgressReport) -> NefCompiler.Compiler.Environment {
        .init(
            progressReport: progressReport,
            fileSystem: MacFileSystem(),
            compilerShell: MacCompilerShell(),
            nefPlaygroundSystem: MacNefPlaygroundSystem(),
            xcodePlaygroundSystem: MacXcodePlaygroundSystem(),
            codePrinter: CoreRender.code.render)
    }
}
