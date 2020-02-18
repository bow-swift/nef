//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import Bow
import BowEffects

public protocol PlaygroundShell {
    func installTemplate(into output: URL, name: String, platform: Platform) -> EnvIO<FileSystem, PlaygroundShellError, NefPlaygroundURL>
    func setDependencies(_ dependencies: PlaygroundDependencies,  playground: NefPlaygroundURL, target: String) -> EnvIO<FileSystem, PlaygroundShellError, Void>
    func linkPlaygrounds(_ playgrounds: [URL],  xcworkspace: URL) -> EnvIO<FileSystem, PlaygroundShellError, Void>
}
