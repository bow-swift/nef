//  Copyright © 2019 The nef Authors.

import Foundation

public extension String {
    
    var pathComponents: [String] {
        (self as NSString).pathComponents
    }
    
    var filename: String {
        pathComponents.last ?? ""
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
    
    var trimmingEmptyCharacters: String {
        trimmingCharacters(in: ["\n", " " ])
    }
    
    private func removeLastComponent(separatedBy separator: String) -> String {
        var pathComponents = components(separatedBy: separator)
        pathComponents.removeLast()
        return pathComponents.joined(separator: separator)
    }
}
