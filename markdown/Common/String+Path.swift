//  Copyright © 2019 The nef Authors.

import Foundation

public extension String {
    
    var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }
}
