//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RendererURL {
    public let url: URL
    public let title: String
    public let escapedTitle: String
}

// MARK: - public <helpers>
extension RendererURL: CustomStringConvertible {
    public var description: String { title }
}

extension RendererURL {
    public func io<E: Error>() -> IO<E, RendererURL> {
        IO.pure(self)^
    }
}
