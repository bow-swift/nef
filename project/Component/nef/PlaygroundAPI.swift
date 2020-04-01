//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefPlayground

import Bow
import BowEffects


public extension PlaygroundAPI {
    
    static func nef(
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        NefPlayground.Playground()
            .build(name: name,
                   output: output,
                   platform: platform,
                   dependencies: dependencies)
            .contramap { progressReport in NefPlayground.PlaygroundEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    nefPlaygroundSystem: MacNefPlaygroundSystem(),
                    xcodePlaygroundSystem: MacXcodePlaygroundSystem())
            }^
            .mapError { _ in .playground() }
    }
    
    static func nef(
        xcodePlayground: URL,
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<ProgressReport, nef.Error, URL> {
        
        NefPlayground.Playground()
            .build(
                xcodePlayground: xcodePlayground,
                name: name,
                output: output,
                platform: platform,
                dependencies: dependencies)
            .contramap { progressReport in NefPlayground.PlaygroundEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    nefPlaygroundSystem: MacNefPlaygroundSystem(),
                    xcodePlaygroundSystem: MacXcodePlaygroundSystem())
            }^
            .mapError { _ in .playground() }
    }
}
