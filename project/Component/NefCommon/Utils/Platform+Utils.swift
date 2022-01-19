//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels

public extension Platform {
    var sdk: String {
        switch self {
        case .ios:     return "iphoneos"
        case .macos:   return "macosx"
        case .tvos:    return "tvos"
        case .watchos: return "watchos"
        }
    }

    var framework: String {
        switch self {
        case .ios:     return "iPhoneOS"
        case .macos:   return "MacOSX"
        case .tvos:    return "AppleTVOS"
        case .watchos: return "WatchOS"
        }
    }

    func target(bundleVersion: String, isM1: Bool) -> String? {
        switch self {
        case .ios:     return "arm64-apple-ios\(bundleVersion)"
        case .macos:   return isM1 ? "arm64-apple-macosx\(bundleVersion)" : "x86_64-macosx\(bundleVersion)"
        default: return nil
        }
    }
}

