//  Copyright © 2019 The nef Authors.

import Foundation

struct Module: Codable {
    let name: String
    let path: String
    let type: Type
    let moduleType: ModuleType
    let sources: [String]
    
    enum ModuleType: String, Codable {
        case swift = "SwiftTarget"
        case clang = "ClangTarget"
    }

    enum `Type`: String, Codable {
        case test
        case library
        case executable
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case path
        case type
        case moduleType = "module_type"
        case sources
    }
}

extension Module: CustomStringConvertible {
    var description: String { name }
}
