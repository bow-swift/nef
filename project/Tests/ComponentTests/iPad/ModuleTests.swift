//  Copyright © 2019 The nef Authors.

import XCTest
@testable import NefiPad

class ModuleTests: XCTestCase {
    private let file = File()
    
    func testTotalModulesGetFromDescribe_ShouldBeTheSameAsNamesInModuleSection() {
        let raw = file.loadRaw(fileName: "bow-describe", extension: "txt")!
        let total = raw.components(separatedBy: "Modules").last!.clean("\n", " ", ":").components(separatedBy: "Name").filter { !$0.isEmpty }.count
        let modules = Module.modules(from: raw)
        
        XCTAssertTrue(modules.count == total, "Total modules in file (\(total)) != Total modules decode (\(modules.count))")
    }
    
    func testModules_Codable() {
        let raw = file.loadRaw(fileName: "bow-describe", extension: "txt")!
        
        let modules = Module.modules(from: raw)
        let modulesData = try! JSONEncoder().encode(modules)
        let modulesCodable = try! JSONDecoder().decode([Module].self, from: modulesData)
        
        XCTAssertEqual(modules, modulesCodable)
    }
    
    func testTheWholeModulesHasSources() {
        let raw = file.loadRaw(fileName: "bow-describe", extension: "txt")!
        let modules = Module.modules(from: raw)
        
        modules.forEach { module in
            XCTAssertTrue(module.sources.count > 0, "Module \(module.name) has not any sources")
        }
    }
}
