//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol FileSystem {
    func write(content: String, toFile: URL) -> IO<RenderSystemError, Void>
    func createDirectory(at url: URL) -> IO<RenderSystemError, Void>
    func exist(directory: URL) -> Bool
    func removeFile(at url: URL) -> IO<RenderSystemError, Void>
}
