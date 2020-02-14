//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import NefSwiftPlayground

import Bow
import BowEffects


extension PlaygroundAPI {
    
    public static func nef(fromPlayground playground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        fatalError()
    }
    
    public static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        fatalError()
    }
}
