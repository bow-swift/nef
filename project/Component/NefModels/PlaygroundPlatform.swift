//  Copyright © 2020 The nef Authors.

import Foundation

/// Models the different platforms in the Apple ecosystem.
public enum Platform: String {
    /// Represents the iOS platform.
    case ios
    
    /// Represents the macOS platform.
    case macos
    
    /// Represents the tvOS platform.
    case tvos
    
    /// Represents the watchOS platform.
    case watchos
    
    /// Initializes a `Platform`
    ///
    /// - Parameter platform: a textual `Platform`.
    public init?(platform: String) {
        guard let platform = Platform(rawValue: platform) else { return nil }
        self = platform
    }
}
