//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol RenderSystem {
    func write(content: String, toFile: URL) -> IO<RenderSystemError, Void>
    func createDirectory(at url: URL) -> IO<RenderSystemError, Void>
    func removeFile(at url: URL) -> IO<RenderSystemError, Void>
}
