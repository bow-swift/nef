//  Copyright © 2020 The nef Authors.

import Foundation
import Bow

public struct RendererPlaygrounds {
    public let playgrounds: NEA<RendererPlayground>
}

public struct RendererPlayground {
    public let playground: RendererURL
    public let pages: NEA<RendererURL>
}

public struct RendererURL {
    public let url: URL
    public let title: String
    public let escapedTitle: String
}

extension RendererURL: CustomStringConvertible {
    public var description: String { title }
}
