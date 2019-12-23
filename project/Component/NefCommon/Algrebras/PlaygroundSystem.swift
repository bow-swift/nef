//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol PlaygroundSystem {
    func name(_ playground: URL) -> IO<PlaygroundSystemError, String>
    func unique(playground: URL, in path: URL) -> IO<PlaygroundSystemError, URL>
    func playgrounds(in path: URL) -> IO<PlaygroundSystemError, [PlaygroundURL<Project>]>
    func pages(in playground: URL) -> IO<PlaygroundSystemError, [PlaygroundURL<Page>]>
}
