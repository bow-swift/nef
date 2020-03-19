//  Copyright © 2019 The nef Authors.

import Foundation

public extension String {
    func clean(_ ocurrences: String...) -> String {
        return ocurrences.reduce(self) { (output, ocurrence) in
            output.replacingOccurrences(of: ocurrence, with: "")
        }
    }
    
    var firstCapitalized: String {
        (first?.uppercased() ?? "") + dropFirst()
    }
    
    var firstLowercased: String {
        (first?.lowercased() ?? "") + dropFirst()
    }
    
    func matches(pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return [] }
        return regex.matches(in: self, range: NSRange(location: 0, length: self.count))
                    .map { match in NSString(string: "\(self)").substring(with: match.range) as String }
    }
    
    func replacingFirstOccurrence(of: String, with: String) -> String {
        guard let range = range(of: of) else { return self }
        return replacingCharacters(in: range, with: with)
    }
}

// MARK: manage errors
public typealias ErrorStringConvertible = Error & CustomStringConvertible

public extension String {
    func appending(error: ErrorStringConvertible?) -> String {
        if let e = error {
            return "\(self): \(e)"
        } else {
            return self
        }
    }
    
    func appending(error: String) -> String {
        "\(self)\(error.isEmpty ? "" : ": \(error)")"
    }
}
