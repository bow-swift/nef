//  Copyright © 2020 The nef Authors.

import Foundation

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
