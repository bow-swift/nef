//  Copyright © 2020 The nef Authors.

import Foundation

/// Workspace dependencies
public struct WorkspaceInfo {
    /// Set SDK for the given platform.
    public let platform: Platform
    /// Specifies frameworks directories to search path.
    public let frameworks: [URL]
    /// Specifies swift modules directories to search path.
    public let modules: [URL]
    /// Specifies binaries for the swiftmodules
    public let binaries: [URL]
    /// Specifies sources which should be passed to the linker.
    public let linkers: [URL]
    /// Specifies directories to library link search path.
    public let libs: [URL]
    
    /// Initializes `WorkspaceInfo`
    ///
    /// - Parameters:
    ///   - platform: Set SDK for the given platform.
    ///   - frameworks: List of the frameworks.
    ///   - modules: List of the modules.
    ///   - binaries: List of the binaries.   
    ///   - linkers: List of the sources which should be passed to the linker.
    ///   - libs: List of the libraries.
    public init(platform: Platform, frameworks: [URL], modules: [URL], binaries: [URL], linkers: [URL], libs: [URL]) {
        self.platform = platform
        self.frameworks = frameworks
        self.modules = modules
        self.binaries = binaries
        self.linkers = linkers
        self.libs = libs
    }
}
