//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground

import Bow
import BowEffects

extension SwiftPlaygroundAPI {
    
    public static func render(packageContent: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL> {
        render(packageContent: packageContent, name: name, output: output, excludeModules: [])
    }
    
    public static func render(packageContent: String, name: String, output: URL, excludeModules: [String]) -> EnvIO<Console, nef.Error, URL> {
        let invalidModules = ["RxTest", "RxBlocking"]
        
        return NefSwiftPlayground.SwiftPlayground(packageContent: packageContent, name: name, output: output)
                                 .build(cached: true, excludeModules: excludeModules + invalidModules)
                                 .contramap { console in PlaygroundEnvironment(console: console, storage: MacFileSystem()) }^
                                 .map { _ in output }^
                                 .mapError { _ in .swiftPlaygrond }^
    }
}
