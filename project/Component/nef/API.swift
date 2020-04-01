//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects

/// Instance of the Playground API
public enum Playground: PlaygroundAPI {}

/// Instance of the Swift Playground API
public enum SwiftPlayground: SwiftPlaygroundAPI {}

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

/// Describes the API for `Swift Playground`
public protocol SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(packageContent: String, name: String, output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - package: Swift Package file.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(package: URL, name: String, output: URL) -> EnvIO<ProgressReport, nef.Error, URL>
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    ///   - excludes: List of items to exclude for building the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`. 
    static func render(packageContent: String, name: String, output: URL, excludes: [PlaygroundExcludeItem]) -> EnvIO<ProgressReport, nef.Error, URL>
}
