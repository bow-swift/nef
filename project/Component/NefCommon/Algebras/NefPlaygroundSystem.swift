//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import Bow
import BowEffects

public protocol NefPlaygroundSystem {
    func installTemplate(into output: URL, name: String, platform: Platform) -> EnvIO<FileSystem, NefPlaygroundSystemError, NefPlaygroundURL>
    func setDependencies(_ dependencies: PlaygroundDependencies, playground: NefPlaygroundURL, inXcodeproj: URL, target: String) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func linkPlaygrounds(_ playgrounds: NEA<URL>,  xcworkspace: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func clean(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
}
