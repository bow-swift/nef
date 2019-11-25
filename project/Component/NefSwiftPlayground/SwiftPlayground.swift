//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Bow
import BowEffects


public struct SwiftPlayground {
    private let resolvePath: ResolvePath
    private let packageContent: String
    
    public init(packageContent: String, name: String, output: URL) {
        self.packageContent = packageContent
        self.resolvePath = ResolvePath(projectName: name, outputPath: output.path)
    }
    
    public func build(cached: Bool) -> EnvIO<iPadApp, SwiftPlaygroundError, Void> {
        fatalError()
    }
}

