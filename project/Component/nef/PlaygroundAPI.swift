//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefPlayground

import Bow
import BowEffects


extension PlaygroundAPI {
    
    public static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        NefPlayground.Playground()
                     .build(name: name, output: output, platform: platform, dependencies: dependencies)
                     .contramap { console in NefPlayground.PlaygroundEnvironment(console: console,
                                                                                 fileSystem: MacFileSystem(),
                                                                                 nefPlaygroundSystem: MacNefPlaygroundSystem(),
                                                                                 xcodePlaygroundSystem: MacXcodePlaygroundSystem()) }^
                     .mapError { _ in .playground() }
    }
    
    public static func nef(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        NefPlayground.Playground()
                     .build(xcodePlayground: xcodePlayground, name: name, output: output, platform: platform, dependencies: dependencies)
                     .contramap { console in NefPlayground.PlaygroundEnvironment(console: console,
                                                                                 fileSystem: MacFileSystem(),
                                                                                 nefPlaygroundSystem: MacNefPlaygroundSystem(),
                                                                                 xcodePlaygroundSystem: MacXcodePlaygroundSystem()) }^
                     .mapError { _ in .playground() }
    }
}
