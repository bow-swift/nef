//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RenderingURL {
    public let url: URL
    public let title: String

    public var escapedTitle: String {
        String(title.lowercased().unicodeScalars.filter { $0.isAlphanumeric || $0 == " " || $0 == "-" })
            .replacingOccurrences(of: " ", with: "-")
    }
    
    public init(url: URL, title: String) {
        self.url = url
        self.title = title
    }
}

extension Unicode.Scalar {
    var isAlphanumeric: Bool {
        CharacterSet.alphanumerics.contains(self)
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
