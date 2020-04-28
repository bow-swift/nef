//  Copyright © 2020 The nef Authors.

import Foundation

public struct CompilerOptions {
    public let sources: [URL]
    public let platform: Platform
    public let frameworks: [URL]
    public let linkers: [URL]
    public let libs: [URL]
    
    public init(sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL], libs: [URL]) {
        self.sources = sources
        self.platform = platform
        self.frameworks = frameworks
        self.linkers = linkers
        self.libs = libs
    }
}
