//  Copyright © 2019 The nef Authors.

import Foundation

public extension String {
    
    var filename: String {
        return components(separatedBy: "/").last ?? ""
    }
    
    var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }
}
