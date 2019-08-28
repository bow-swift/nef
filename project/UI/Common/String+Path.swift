//  Copyright © 2019 The nef Authors.

import Foundation

public extension String {
    
    var filename: String {
        components(separatedBy: "/").last ?? ""
    }
    
    var removeExtension: String {
        removeLastComponent(separatedBy: ".")
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
