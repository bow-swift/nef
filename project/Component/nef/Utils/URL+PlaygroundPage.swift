//  Copyright © 2020 The nef Authors.

import Foundation

extension URL {
    var playgroundPage: URL {
        path.contains("Contents.swift") ? self : appendingPathComponent("Contents.swift")
    }
    
    var contentPage: String? {
        try? String(contentsOfFile: playgroundPage.path)
    }
    
    var pageName: String {
        playgroundPage.deletingLastPathComponent().lastPathComponent.removeExtension
    }
}
