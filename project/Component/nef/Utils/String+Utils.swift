//  Copyright © 2019 The nef Authors.

import Foundation

extension String {
    func matches(pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return [] }
        return regex.matches(in: self, range: NSRange(location: 0, length: self.count))
                    .map { match in NSString(string: "\(self)").substring(with: match.range) as String }
    }
}
