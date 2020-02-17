//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

public protocol PlaygroundShell {
    func downloadTemplate(into output: URL, name: String, platform: Platform) -> IO<PlaygroundShellError, URL>
}
