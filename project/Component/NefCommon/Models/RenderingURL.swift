//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RenderingURL {
    public let url: URL
    public let title: String

    public var escapedTitle: String {
        title.lowercased().replacingOccurrences(of: "?", with: "-")
                          .replacingOccurrences(of: "→", with: "")
                          .replacingOccurrences(of: " ", with: "-")
    }
    
    public init(url: URL, title: String) {
        self.url = url
        self.title = title
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
