//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels
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
        
//        guard let packageContent = try? String(contentsOf: package),
//              !packageContent.isEmpty else {
//            return EnvIO.raiseError(.swiftPlayground(info: "Error: invalid Swift Package"))^
//        }
        
        let packageContent = """
                             // swift-tools-version:5.2
                             import PackageDescription

                             extension Target {
                                 var asDependency: Target.Dependency {
                                     .target(name: name)
                                 }
                             }

                             // MARK: - Libraries
                             extension Target {
                                 static var libraries: [Target] {
                                     [
                                         .bow,
                                         .bowOptics,
                                         .bowRecursionSchemes,
                                         .bowFree,
                                         .bowGeneric,
                                         .bowEffects,
                                         .bowRx,
                                     ]
                                 }

                                 static var bow: Target {
                                     .target(name: "Bow")
                                 }

                                 static var bowOptics: Target {
                                     .target(name: "BowOptics",
                                             dependencies: [Target.bow.asDependency])
                                 }

                                 static var bowEffects: Target {
                                     #if os(Linux)
                                     return .target(name: "BowEffects",
                                                    dependencies: [Target.bow.asDependency],
                                                    exclude: ["Foundation/FileManager+iOS+Mac.swift"])
                                     #else
                                     return .target(name: "BowEffects",
                                                    dependencies: [Target.bow.asDependency])
                                     #endif
                                 }

                                 static var bowRecursionSchemes: Target {
                                     .target(name: "BowRecursionSchemes",
                                             dependencies: [Target.bow.asDependency])
                                 }

                                 static var bowFree: Target {
                                     .target(name: "BowFree",
                                             dependencies: [Target.bow.asDependency])
                                 }

                                 static var bowGeneric: Target {
                                     .target(name: "BowGeneric",
                                             dependencies: [Target.bow.asDependency])
                                 }

                                 static var bowRx: Target {
                                     .target(name: "BowRx",
                                             dependencies: [Target.bow.asDependency,
                                                            Target.bowEffects.asDependency,
                                                            .product(name: "RxSwift", package: "RxSwift"),
                                                            .product(name: "RxCocoa", package: "RxSwift")])
                                 }
                             }

                             // MARK: - Laws
                             extension Target {
                                 static var laws: [Target] {
                                     [
                                         .bowLaws,
                                         .bowEffectsLaws,
                                         .bowOpticsLaws,
                                     ]
                                 }

                                 static var bowLaws: Target {
                                     .target(name:"BowLaws",
                                             dependencies: [Target.bowGenerators.asDependency],
                                             path: "Tests/BowLaws")
                                 }

                                 static var bowEffectsLaws: Target {
                                     .target(name:"BowEffectsLaws",
                                             dependencies: [Target.bowEffects.asDependency,
                                                            Target.bowLaws.asDependency],
                                             path: "Tests/BowEffectsLaws")
                                 }

                                 static var bowOpticsLaws: Target {
                                     .target(name:"BowOpticsLaws",
                                             dependencies: [Target.bowOptics.asDependency,
                                                            Target.bowLaws.asDependency],
                                             path: "Tests/BowOpticsLaws")

                                 }
                             }

                             // MARK: - Generators
                             extension Target {
                                 static var generators: [Target] {
                                     [
                                         .bowGenerators,
                                         .bowFreeGenerators,
                                         .bowEffectsGenerators,
                                         .bowRxGenerators,
                                     ]
                                 }

                                 static var bowGenerators: Target {
                                     .target(name: "BowGenerators",
                                             dependencies: [Target.bow.asDependency,
                                                            .product(name: "SwiftCheck", package: "SwiftCheck")],
                                             path: "Tests/BowGenerators")
                                 }

                                 static var bowFreeGenerators: Target {
                                     .target(name: "BowFreeGenerators",
                                             dependencies: [Target.bowFree.asDependency,
                                                            Target.bowGenerators.asDependency],
                                             path: "Tests/BowFreeGenerators")
                                 }

                                 static var bowEffectsGenerators: Target {
                                     .target(name: "BowEffectsGenerators",
                                             dependencies: [Target.bowEffects.asDependency,
                                                            Target.bowGenerators.asDependency],
                                             path: "Tests/BowEffectsGenerators")
                                 }

                                 static var bowRxGenerators: Target {
                                     .target(name: "BowRxGenerators",
                                             dependencies: [Target.bowRx.asDependency,
                                                            Target.bowGenerators.asDependency],
                                             path: "Tests/BowRxGenerators")
                                 }
                             }

                             // MARK:  - Tests
                             extension Target {
                                 static var tests: [Target] {
                                     [
                                         .bowTests,
                                         .bowOpticsTests,
                                         .bowRecursionSchemesTests,
                                         .bowFreeTests,
                                         .bowGenericTests,
                                         .bowEffectsTests,
                                         .bowRxTests,
                                     ]
                                 }

                                 static var bowTests: Target {
                                     .testTarget(name: "BowTests",
                                                 dependencies: [Target.bowLaws.asDependency])
                                 }

                                 static var bowOpticsTests: Target {
                                     .testTarget(name: "BowOpticsTests",
                                                 dependencies: [Target.bowOpticsLaws.asDependency])
                                 }

                                 static var bowRecursionSchemesTests: Target {
                                     .testTarget(name: "BowRecursionSchemesTests",
                                                 dependencies: [Target.bowRecursionSchemes.asDependency,
                                                                Target.bowLaws.asDependency])
                                 }

                                 static var bowFreeTests: Target {
                                     .testTarget(name: "BowFreeTests",
                                                 dependencies: [Target.bowFreeGenerators.asDependency,
                                                                Target.bowLaws.asDependency])
                                 }

                                 static var bowGenericTests: Target {
                                     .testTarget(name: "BowGenericTests",
                                                 dependencies: [Target.bowGeneric.asDependency])
                                 }

                                 static var bowEffectsTests: Target {
                                     .testTarget(name: "BowEffectsTests",
                                                 dependencies: [Target.bowEffectsGenerators.asDependency,
                                                                Target.bowEffectsLaws.asDependency])
                                 }

                                 static var bowRxTests: Target {
                                     .testTarget(name: "BowRxTests",
                                                 dependencies: [Target.bowRxGenerators.asDependency,
                                                                Target.bowEffectsGenerators.asDependency,
                                                                Target.bowEffectsLaws.asDependency])
                                 }
                             }


                             // MARK: - Package
                             let package = Package(
                                 name: "Bow",

                                 products: [
                                     .library(name: Target.bow.name,                  targets: [Target.bow.name]),
                                     .library(name: Target.bowOptics.name,            targets: [Target.bowOptics.name]),
                                     .library(name: Target.bowRecursionSchemes.name,  targets: [Target.bowRecursionSchemes.name]),
                                     .library(name: Target.bowFree.name,              targets: [Target.bowFree.name]),
                                     .library(name: Target.bowEffects.name,           targets: [Target.bowEffects.name]),
                                     .library(name: Target.bowRx.name,                targets: [Target.bowRx.name]),

                                     .library(name: Target.bowLaws.name,              targets: [Target.bowLaws.name]),
                                     .library(name: Target.bowOpticsLaws.name,        targets: [Target.bowOpticsLaws.name]),
                                     .library(name: Target.bowEffectsLaws.name,       targets: [Target.bowEffectsLaws.name]),

                                     .library(name: Target.bowGenerators.name,        targets: [Target.bowGenerators.name]),
                                     .library(name: Target.bowFreeGenerators.name,    targets: [Target.bowFreeGenerators.name]),
                                     .library(name: Target.bowEffectsGenerators.name, targets: [Target.bowEffectsGenerators.name]),
                                     .library(name: Target.bowRxGenerators.name,      targets: [Target.bowRxGenerators.name])
                                 ],

                                 dependencies: [
                                     .package(url: "https://github.com/bow-swift/SwiftCheck.git", from: "0.12.1"),
                                     .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.1"),
                                 ],

                                 targets: [
                                     Target.libraries,
                                     Target.laws,
                                     Target.generators,
                                     Target.tests,
                                 ].flatMap { $0 }
                             )

                             """
        
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
                    shell: UnixPackageShell(),
                    system: UnixFileSystem())
            }^
            .map { _ in output.appendingPathComponent(name).appendingPathComponent("\(name).playgroundbook") }^
            .mapError { e in .swiftPlayground(info: "\(e)") }^
    }
}
