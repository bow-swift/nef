//  Copyright © 2019 The nef Authors.

import XCTest
@testable import NefiPad

class ModuleTests: XCTestCase {
    
    func testMigue() {
        let module = Module(name: "migue", path: "adios", type: .test, language: .swift, sources: ["hola"])
        module.name
    }
}
