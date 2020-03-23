//  Copyright © 2020 The nef Authors.

import Foundation

/// Models the different platforms in the Apple ecosystem.
///
/// - ios: represents the iOS platform.
/// - macos: represents the macOS platform.
/// - tvos: represents the tvOS platform.
/// - watchos: represents the watchOS platform.
public enum Platform: String {
    case ios
    case macos
    case tvos
    case watchos
    
    public init?(platform: String) {
        guard let platform = Platform(rawValue: platform) else { return nil }
        self = platform
    }
}
