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
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case path = "Path"
        case type = "Type"
        case moduleType = "Module type"
        case sources = "Sources"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        path = try container.decode(String.self, forKey: .path)
        type = try container.decode(Type.self, forKey: .type)
        moduleType = try container.decode(ModuleType.self, forKey: .moduleType)
        
        let sourcesRaw = try container.decode(String.self, forKey: .sources)
        sources = sourcesRaw.components(separatedBy: ",").map { $0.trimmingEmptyCharacters }
    }
}

// MARK: - Helpers
extension Module {
    typealias ModuleDict = [String : String]

    static func modules(from raw: String) -> [Module] {
        guard let jsonObject = moduleSection(from: raw).flatMap(modulesRaw).flatMap(modulesDict),
              let modulesJSON = try? JSONSerialization.data(withJSONObject: jsonObject, options: .sortedKeys),
              let modules = try? JSONDecoder().decode([Module].self, from: modulesJSON) else { return [] }
        
        return modules
    }
    
    private static func moduleSection(from raw: String) -> String? {
        return raw.components(separatedBy: "Modules:").last
    }
    
    private static func modulesRaw(fromModuleSection section: String) -> [String] {
        return section.components(separatedBy: "Name: ").compactMap { m in
            let module = m.trimmingEmptyCharacters
            return !module.isEmpty ? "Name: \(module)" : nil
        }
    }
    
    private static func modulesDict(fromModulesRaw modulesRaw: [String]) -> [ModuleDict] {
        return modulesRaw.map { module in
            let elements = module.components(separatedBy: "\n")
            return elements.map { $0.components(separatedBy: ":") }.reduce(into: ModuleDict(), { (acc, pair) in
                guard pair.count == 2 else { return }
                let (key, value) = (pair[0].trimmingEmptyCharacters, pair[1].trimmingEmptyCharacters)
                acc[key] = value
            })
        }
    }
}
