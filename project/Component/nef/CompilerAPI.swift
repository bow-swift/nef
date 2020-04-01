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

/// Describes the API for `Compiler`
public protocol CompilerAPI {
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - nefPlayground: Folder where to search Xcode Playgrounds - it must be a nef Playground structure.
    ///   - cached: Use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport,.
    static func compile(
        nefPlayground: URL,
        cached: Bool
    ) -> EnvIO<ProgressReport, nef.Error, Void>
}

public extension CompilerAPI {
    /// Compile Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playgrounds to be compiled.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: To use for the compiler.
    ///   - cached: Use cached dependencies if it is possible, in another case, it will download them.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport,.
    static func compile(
        xcodePlayground: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies,
        cached: Bool
    ) -> EnvIO<ProgressReport, nef.Error, Void> {
        
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
}

/// Instance of the Compiler API
public enum Compiler: CompilerAPI {
    public static func compile(nefPlayground: URL, cached: Bool) -> EnvIO<ProgressReport, nef.Error, Void> {
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
