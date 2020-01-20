//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RenderingURL {
    public let url: URL
    public let title: String
    public let escapedTitle: String
    
    public init(url: URL, title: String, escapedTitle: String) {
        self.url = url
        self.title = title
        self.escapedTitle = escapedTitle
    }
}

// MARK: - public <helpers>
extension RenderingURL: CustomStringConvertible {
    public var description: String { title }
}

extension RenderingURL {
    public func io<E: Error>() -> IO<E, RenderingURL> {
        IO.pure(self)^
    }
}


