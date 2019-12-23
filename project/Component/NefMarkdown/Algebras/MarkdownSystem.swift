//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol MarkdownSystem {
    func write(content: String, toFile: URL) -> IO<MarkdownSystemError, Void>
    func createDirectory(at url: URL) -> IO<MarkdownSystemError, Void>
    func removeFile(at url: URL) -> IO<MarkdownSystemError, Void>
}
