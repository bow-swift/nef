//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground

import Bow
import BowEffects

extension SwiftPlaygroundAPI {
    
    public static func render(packageContent: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL> {
        NefSwiftPlayground.SwiftPlayground(packageContent: packageContent, name: name, output: output)
                          .build(cached: true)
                          .contramap { console in iPadApp(console: console, storage: MacFileSystem()) }^
                          .map { _ in output }^
                          .mapError { _ in .swiftPlaygrond }^
    }
}
