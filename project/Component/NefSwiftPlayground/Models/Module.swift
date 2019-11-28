//  Copyright © 2019 The nef Authors.

import Foundation
import BowOptics

struct Module: Codable, AutoLens {
    var name: String
    var path: String
    let type: Type
    let moduleType: ModuleType
    var sources: [String]
    
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

extension Module {
    static let sourcesTraversal = [Module].traversal + Module.lens(for: \.sources)
    static let moduleNameAndSourcesTraversal = [Module].traversal + Module.lens(for: \.name).merge(Module.lens(for: \.sources))
    static let modulePathAndSourcesTraversal = [Module].traversal + Module.lens(for: \.path).merge(Module.lens(for: \.sources))
}
