import Foundation

// MARK: Helpers
// MARK: - <string>

typealias SubstringType = (ouput: String, range: NSRange)

extension String {
    func substring(pattern: String) -> SubstringType? {
        let range = NSRange(location: 0, length: self.utf8.count)
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: self, options: [], range: range) else { return nil }

        let output = NSString(string: self).substring(with: match.range) as String

        return (output, match.range)
    }

    func advance(_ offset: Int) -> String {
        return NSString(string: self).substring(from: offset) as String
    }

    func clean(_ ocurrences: String...) -> String {
        return ocurrences.reduce(self) { (output, ocurrence) in
            output.replacingOccurrences(of: ocurrence, with: "")
        }
    }

    var trimmingWhitespaces: String {
        return trimmingCharacters(in: .whitespaces)
    }
}
