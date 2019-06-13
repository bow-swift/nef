//  Copyright © 2019 The nef Authors.

import Foundation

// MARK: Constants
extension URLRequest {
    static let URLLenghtLimit = 5200
}

// MARK: URL Query <actions>
extension String {
    var requestPathEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    func urlLength(limit length: Int) -> String {
        guard count > length else { return self }
        
        let sliced = compactMap { $0 }[0..<length]
        let slicedQuery = sliced.dropLast(while: { $0 != "%" }, include: false)
        return slicedQuery.reduce(into: "") { (acc, char) in acc = "\(acc)\(char)" }
    }
}
