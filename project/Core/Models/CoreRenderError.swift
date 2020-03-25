//  Copyright © 2020 The nef Authors.

import Foundation

public enum CoreRenderError: Error, Equatable {
    case ast
    case renderNode(String)
    case renderEmpty
}

extension CoreRenderError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ast:
            return "Syntax analysis fails. Review all the delimiters open/close are correct."
        case .renderNode(let node):
            return "Could not render the node: \n\(node)\n"
        case .renderEmpty:
            return "Render result was empty. Review the page and the nef hidden blocks."
        }
    }
}
