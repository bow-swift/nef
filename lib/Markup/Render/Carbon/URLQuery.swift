//  Copyright © 2019 The nef Authors.

import Foundation

// MARK: Constants
extension URLRequest {
    static let URLLenghtAllowed = 5000
}

// MARK: URL Query <actions>
extension String {
    var requestPathEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    subscript(truncate: Int) -> String {
        guard count > truncate else { return self }
        
        let sliced = compactMap { $0 }[0..<truncate]
        let slicedQuery = sliced.dropLast(while: { $0 != "%" }, include: false)
        return slicedQuery.reduce(into: "") { (acc, char) in acc = "\(acc)\(char)" }
    }
}


