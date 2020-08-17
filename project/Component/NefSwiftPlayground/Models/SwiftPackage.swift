//  Copyright © 2020 The nef Authors.

import Foundation

public struct SwiftPackage: Decodable {
    public let name: String
    public let products: [SwiftPackage.Product]
    public let targets: [SwiftPackage.Target]
    
    // MARK: - Product
    public struct Product: Decodable {
        private enum CodingKeys: String, CodingKey {
            case name
            case targets
            case type
        }
        
        public let name: String
        public let targets: [String]
        public let type: ProductType
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode([String: [String]?].self, forKey: .type)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.targets = try container.decode([String].self, forKey: .targets)
            self.type = ProductType(rawValue: type.first?.key.lowercased() ?? "") ?? .library
        }
    }
    
    public enum ProductType: String {
        case library
        case executable
        case dynamic
    }
    
    
    // MARK: - Target
    public struct Target: Decodable {
        private enum CodingKeys: String, CodingKey {
            case name
            case dependencies
        }
        
        public let name: String
        public let dependencies: Dependencies
        
        public struct Dependencies: Decodable {
            public let targets: [String]
            public let products: [String]
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dependencies = try container.decode([[String: [String]]].self, forKey: .dependencies)
            let targets = dependencies.filter { dependency in dependency.keys.first?.lowercased() != "product" }
            let products = dependencies.filter { dependency in dependency.keys.first?.lowercased() == "product" }
            let flattenTargets = targets.flatMap(\.values).flatMap { $0 }.unique()
            let flattenProducts = products.flatMap(\.values).flatMap { $0 }.unique()
            
            self.name = try container.decode(String.self, forKey: .name)
            self.dependencies = Dependencies(targets: flattenTargets, products: flattenProducts)
        }
    }
}
