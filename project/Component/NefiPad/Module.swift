//  Copyright © 2019 The nef Authors.

import Foundation

struct Module: Codable {
    let name: String
    let path: String
    let type: ModuleType
    let language: Language
    let sources: [String]
    
    enum Language: String, Codable {
        case swift = "SwiftTarget"
        case clang = "ClangTarget"
    }

    enum ModuleType: String, Codable {
        case test
        case library
        case executable
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case path = "Path"
        case type = "Type"
        case language = "Module type"
        case sources = "Sources"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        path = try container.decode(String.self, forKey: .path)
        type = try container.decode(ModuleType.self, forKey: .type)
        language = try container.decode(Language.self, forKey: .language)
        
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

// MARK: - testing proposals
extension Module {
    init(name: String, path: String, type: ModuleType, language: Language, sources: [String]) {
        self.name = name
        self.path = path
        self.type = type
        self.language = language
        self.sources = sources
    }
}
