//  Copyright © 2019 The nef Authors.

import Foundation
import Swiftline

let path = "/Users/miguelangel/Desktop/BowMigue/.build/checkouts/Bow"
let package = "\(path)/Package.swift"

let result = run("swift package --package-path \(path) describe")
print(result.stdout)
print(result.stderr)

if let res = result.stdout {
    res.spli
}

