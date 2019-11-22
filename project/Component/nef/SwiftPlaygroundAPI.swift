//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground

import Bow
import BowEffects

extension SwiftPlaygroundAPI {
    
    public static func render(package: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL> {
        NefSwiftPlayground.SwiftPlayground(packageContent: package, name: name, output: output)
                          .build(cached: true)
                          .map { _ in output }^
                          .mapError { _ in .swiftPlaygrond }^
    }
}
