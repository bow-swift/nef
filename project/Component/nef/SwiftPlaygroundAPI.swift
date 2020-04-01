//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground
import Bow
import BowEffects

/// Describes the API for `Swift Playground`
public protocol SwiftPlaygroundAPI {
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    ///   - excludes: List of items to exclude for building the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        packageContent: String,
        name: String,
        output: URL,
        excludes: [PlaygroundExcludeItem]
    ) -> EnvIO<ProgressReport, nef.Error, URL>
}

public extension SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - packageContent: Swift Package content.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        packageContent: String,
        name: String,
        output: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        render(packageContent: packageContent, name: name, output: output, excludes: [])
    }
    
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - package: Swift Package file.
    ///   - name: Name for the output Swift Playground.
    ///   - output: Folder where to write the Swift Playground.
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `ProgressReport`.
    static func render(
        package: URL,
        name: String,
        output: URL
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        guard let packageContent = try? String(contentsOfFile: package.path),
            !packageContent.isEmpty else {
            return EnvIO.raiseError(.swiftPlaygrond(info: "Error: invalid Swift Package"))^
        }
        
        return render(packageContent: packageContent, name: name, output: output)
    }
}

/// Instance of the Swift Playground API
public enum SwiftPlayground: SwiftPlaygroundAPI {
    static let invalidModules: [PlaygroundExcludeItem] = [
        .module(name: "RxSwift"),
        .module(name: "RxRelay"),
        .module(name: "RxTest"),
        .module(name: "RxBlocking"),
        .module(name: "RxCocoa"),
        .module(name: "SwiftCheck"),
        .module(name: "Swiftline"),
        .module(name: "BowRx"),
        .module(name: "BowGenerators"),
        .module(name: "BowEffectsGenerators"),
        .module(name: "BowRxGenerators"),
        .module(name: "BowFreeGenerators"),
        .module(name: "BowLaws"),
        .module(name: "BowEffectsLaws"),
        .module(name: "BowOpticsLaws")
    ]
    
    static let invalidFiles: [PlaygroundExcludeItem] = [
        .file(name: "NetworkReachabilityManager.swift",
              module: "Alamofire")
    ]
    
    public static func render(
        packageContent: String,
        name: String,
        output: URL,
        excludes: [PlaygroundExcludeItem]
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        NefSwiftPlayground.SwiftPlayground(
            packageContent: packageContent, name: name, output: output)
            .build(cached: true,
                   excludes: excludes + invalidModules + invalidFiles)
            .contramap { progressReport in
                PlaygroundEnvironment(
                    progressReport: progressReport,
                    shell: MacPackageShell(),
                    system: MacFileSystem())
            }^
            .map { _ in output.appendingPathComponent(name).appendingPathComponent("\(name).playgroundbook") }^
            .mapError { _ in .swiftPlaygrond() }^
    }
}
