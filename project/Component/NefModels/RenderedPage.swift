//  Copyright © 2020 The nef Authors.

import Foundation

/// Describes the output of a rendered page.
public struct RenderedPage {
    /// Describes nef syntax tree.
    public let ast: String
    /// Rendered output.
    public let rendered: RenderedOutput
    
    /// Initializes `RenderedPage`
    ///
    /// - Parameters:
    ///   - ast: nef syntax-tree.
    ///   - rendered: Rendered output.
    public init(ast: String, rendered: RenderedOutput) {
        self.ast = ast
        self.rendered = rendered
    }
}

/// Describes rendered value.
public enum RenderedOutput {
    /// Specifies the output file path.
    case url(URL)
    /// Rendered value.
    case value(String)
}

public extension RenderedOutput {
    /// Extract content of the rendered page.
    var content: String {
        switch self {
        case .url(let url):
            return (try? String(contentsOf: url)) ?? ""
        case .value(let value):
            return value
        }
    }
}
