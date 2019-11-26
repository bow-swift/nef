//  Copyright © 2019 The Bow Authors.

import Foundation

extension String {
    
    var filename: String {
        components(separatedBy: "/").last ?? ""
    }
    
    var removeExtension: String {
        removeLastComponent(separatedBy: ".")
    }
    
    var `extension`: String {
        components(separatedBy: ".").last ?? ""
    }
    
    var expandingTildeInPath: String {
        NSString(string: self).expandingTildeInPath
    }
    
    var parentPath: String {
        removeLastComponent(separatedBy: "/")
    }
    
    private func removeLastComponent(separatedBy separator: String) -> String {
        var pathComponents = components(separatedBy: separator)
        pathComponents.removeLast()
        return pathComponents.joined(separator: separator)
    }
}

extension StaticString {
    var `string`: String { "\(self)" }
}
