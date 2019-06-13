//  Copyright © 2019 The nef Authors.

import Foundation

// MARK: Constants
extension URLRequest {
    static let URLLenghtLimit = 2500
}

// MARK: URL Query <actions>
extension String {
    
    var urlEncoding: String {
        return replacingOccurrences(of: "+", with: "%2B")
    }
    
    func length(limit: Int) -> String {
        guard count > limit else { return self }
        let sliced = compactMap { $0 }[0..<limit]
        return sliced.reduce(into: "") { (acc, char) in acc = "\(acc)\(char)" }
    }
}
