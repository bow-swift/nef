//  Copyright © 2019 The nef Authors.

import Foundation

extension String {
    var trimmingEmptyCharacters: String {
        return trimmingCharacters(in: ["\n", " " ])
    }
    
    var path: String {
        var pathComponents = components(separatedBy: "/")
        pathComponents.removeLast()
        return pathComponents.joined(separator: "/")
    }
}
