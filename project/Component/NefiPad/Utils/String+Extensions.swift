//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Swiftline

extension String {
    
    var trimmingEmptyCharacters: String {
        return trimmingCharacters(in: ["\n", " " ])
    }
    
    var resolvePath: String {
        let result = run("readlink file \(self)")
        guard result.stdout.isEmpty else {
            return "\(parentPath)/\(result.stdout)".resolvePath
        }
        
        return replacingOccurrences(of: "//", with: "/")
    }
}
