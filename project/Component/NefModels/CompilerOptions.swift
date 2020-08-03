//  Copyright © 2020 The nef Authors.

import Foundation

/// Swift compiler options
public struct CompilerOptions {
    /// Source files to compile.
    public let sources: [URL]
    /// Workspace options.
    public let workspace: WorkspaceInfo
    
    /// Initializes `CompilerOptions`
    ///
    /// - Parameters:
    ///   - sources: Source files to compile.
    ///   - workspace: Workspace information.
    public init(sources: [URL], workspace: WorkspaceInfo) {
        self.sources = sources
        self.workspace = workspace
    }
}
