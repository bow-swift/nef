//  Copyright © 2020 The nef Authors.

import Foundation

/// Swift compiler options
public struct CompilerOptions {
    /// List of the resources.
    public let sources: [URL]
    /// Set SDK for the given platform.
    public let platform: Platform
    /// Specifies directories to framework search path.
    public let frameworks: [URL]
    /// Specifies sources which should be passed to the linker.
    public let linkers: [URL]
    /// Specifies directories to library link search path.
    public let libs: [URL]
    
    /// Initializes `CompilerOptions`
    ///
    /// - Parameters:
    ///   - sources: list of the resources.
    ///   - platform: set SDK for the given platform.
    ///   - frameworks: list of the framworks
    ///   - linkers: list of the sources which should be passed to the linker.
    ///   - libs: list of the libraries.
    public init(sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL], libs: [URL]) {
        self.sources = sources
        self.platform = platform
        self.frameworks = frameworks
        self.linkers = linkers
        self.libs = libs
    }
}
