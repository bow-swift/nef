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

public struct RendererPage {
    public let playground: RendererURL
    public let page: RendererURL
    
    public init(playground: RendererURL, page: RendererURL) {
        self.playground = playground
        self.page = page
    }
}

public struct RendererURL {
    public let url: URL
    public let title: String
    public let escapedTitle: String
}

// MARK: - public <helpers>
extension RendererURL: CustomStringConvertible {
    public var description: String { title }
}

// MARK: - internal <helpers>
extension RendererPage {
    static var empty: RendererPage {
        RendererPage(playground: RendererURL.empty, page: RendererURL.empty)
    }
}

extension RendererURL {
    static var empty: RendererURL {
        RendererURL(url: URL(fileURLWithPath: "RendererURL.empty"), title: "RendererURL.empty", escapedTitle: "RendererURL.empty")
    }
}
