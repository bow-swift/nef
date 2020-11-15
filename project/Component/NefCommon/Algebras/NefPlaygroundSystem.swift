//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

public protocol NefPlaygroundSystem {
    func installTemplate(into output: URL, name: String, platform: Platform) -> EnvIO<FileSystem, NefPlaygroundSystemError, NefPlaygroundURL>
    func linkPlaygrounds(_ playgrounds: NEA<URL>,  xcworkspace: URL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func clean(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func setSPM(playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func setCocoapods(playground: NefPlaygroundURL, target: String, customPodfile: URL?) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func setCarthage(playground: NefPlaygroundURL, xcodeproj: URL, customCartfile: URL?) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
    func setBow(dependency: PlaygroundDependencies.Bow, playground: NefPlaygroundURL) -> EnvIO<FileSystem, NefPlaygroundSystemError, Void>
}
