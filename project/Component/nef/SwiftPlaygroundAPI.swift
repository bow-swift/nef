//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground

import Bow
import BowEffects


extension SwiftPlaygroundAPI {
    
    public static func render(packageContent: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL> {
        render(packageContent: packageContent, name: name, output: output, excludes: [])
    }
    
    public static func render(packageContent: String, name: String, output: URL, excludes: [PlaygroundExcludeItem]) -> EnvIO<Console, nef.Error, URL> {
        let invalidModules: [PlaygroundExcludeItem] = [.module(name: "RxSwift"), .module(name: "RxRelay"), .module(name: "RxTest"), .module(name: "RxBlocking"), .module(name: "RxCocoa"),
                                                       .module(name: "SwiftCheck"),
                                                       .module(name: "Swiftline"),
                                                       .module(name: "BowRx"), .module(name: "BowGenerators"), .module(name: "BowEffectsGenerators"), .module(name: "BowRxGenerators"), .module(name: "BowFreeGenerators"), .module(name: "BowLaws"), .module(name: "BowEffectsLaws"), .module(name: "BowOpticsLaws")]
        let invalidFiles: [PlaygroundExcludeItem]   = [.file(name: "NetworkReachabilityManager.swift", module: "Alamofire")]
        
        return NefSwiftPlayground.SwiftPlayground(packageContent: packageContent, name: name, output: output)
                                 .build(cached: true, excludes: excludes + invalidModules + invalidFiles)
                                 .contramap { console in PlaygroundEnvironment(console: console, shell: MacPackageShell(), system: MacFileSystem()) }^
                                 .map { _ in output.appendingPathComponent(name).appendingPathComponent("\(name).playgroundbook") }^
                                 .mapError { _ in .swiftPlaygrond() }^
    }
}
