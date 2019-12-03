//  Copyright © 2019 The nef Authors.

import Foundation

struct Package: Codable {
    let name: String
    let path: String
    let targets: [Module]
}
