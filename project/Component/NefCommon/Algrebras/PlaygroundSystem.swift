//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol PlaygroundSystem {
    func playgrounds(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>>
    func pages(in playground: URL) -> IO<PlaygroundSystemError, NEA<URL>>
}
