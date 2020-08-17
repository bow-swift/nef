//  Copyright © 2020 The nef Authors.

import Foundation

/// Swift module description
public struct SwiftModule {
    /// Specifies the Swift module name.
    let name: String
    /// Specifies the Swift module directory.
    let url: URL
    /// Specifies path to Swift module.
    public var module: URL {
        url.appendingPathComponent(name).appendingPathExtension("swiftmodule")
    }
    /// Specifies path to Swift module object.
    public var binary: URL {
        url.appendingPathComponent(name).appendingPathExtension("o")
    }
    
    /// Initializes `SwiftModule`
    ///
    /// - Parameters:
    ///   - name: Swift module name.
    ///   - path: Swift module directory.
    public init?(name: String, at path: String) {
        guard let url = URL(string: path) else { return nil }
        self.name = name
        self.url = url
    }
}
