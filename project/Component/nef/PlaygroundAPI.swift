//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
@_exported import NefModels
import NefPlayground
import Bow
import BowEffects

/// Describes the API for `Playground`
public protocol PlaygroundAPI {
    /// Make a nef Playground compatible with 3rd-party libraries.
    ///
    /// - Parameters:
    ///   - name: Name for the output nef Playground.
    ///   - output: Folder where to write the nef Playground.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: Dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Make a nef Playground compatible with 3rd-party libraries from an Xcode Playground.
    ///
    /// - Parameters:
    ///   - xcodePlayground: Xcode Playground to transform to nef Playground.
    ///   - name: Name for the output nef Playground.
    ///   - output: Folder where to write the nef Playground.
    ///   - platform: Target to use for compiling Xcode Playground.
    ///   - dependencies: Dependencies to use for the compiler.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and the nef Playground output of the type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func nef(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<ProgressReport, nef.Error, URL>
}

/// Instance of the Playground API
public enum Playground: PlaygroundAPI {
    public static func nef(
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        NefPlayground.Playground()
            .build(name: name,
                   output: output,
                   platform: platform,
                   dependencies: dependencies)
            .contramap { progressReport in NefPlayground.PlaygroundEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    nefPlaygroundSystem: MacNefPlaygroundSystem(),
                    xcodePlaygroundSystem: MacXcodePlaygroundSystem())
            }^
            .mapError { _ in .playground() }
    }
    
    public static func nef(
        xcodePlayground: URL,
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        NefPlayground.Playground()
            .build(
                xcodePlayground: xcodePlayground,
                name: name,
                output: output,
                platform: platform,
                dependencies: dependencies)
            .contramap { progressReport in NefPlayground.PlaygroundEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    nefPlaygroundSystem: MacNefPlaygroundSystem(),
                    xcodePlaygroundSystem: MacXcodePlaygroundSystem())
            }^
            .mapError { _ in .playground() }
    }
}
