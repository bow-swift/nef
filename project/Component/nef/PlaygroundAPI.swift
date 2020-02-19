//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefPlayground

import Bow
import BowEffects


extension PlaygroundAPI {
    
    public static func nef(fromPlayground playground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        fatalError()
    }
    
    public static func nef(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<Console, nef.Error, URL> {
        NefPlayground.Playground()
                     .build(name: name, output: output, platform: platform, dependencies: dependencies)
                     .contramap { console in NefPlayground.PlaygroundEnvironment(console: console,
                                                                                 shell: MacPlaygroundShell(),
                                                                                 playgroundSystem: MacPlaygroundSystem(),
                                                                                 fileSystem: MacFileSystem()) }^
                     .map { output }^
                     .mapError { _ in .playground() }
    }
}
