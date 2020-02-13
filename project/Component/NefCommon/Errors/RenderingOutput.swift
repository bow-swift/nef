//  Copyright © 2019 The nef Authors.

import Foundation
import Bow

public struct RenderingOutput<A> {
    public let ast: String
    public let output: NEA<A>
    
    public init(ast: String, output: NEA<A>) {
        self.ast = ast
        self.output = output
    }
}

public enum Platform: String {
    case ios
    case macos
    case tvos
    case watchos
    
    public init?(platform: String) {
        guard let platform = Platform(rawValue: platform) else { return nil }
        self = platform
    }
    
    public var sdk: String {
        switch self {
        case .ios:     return "iphoneos"
        case .macos:   return "macosx"
        case .tvos:    return "tvos"
        case .watchos: return "watchos"
        }
    }
    
    public var framework: String {
        switch self {
        case .ios:     return "iPhoneOS"
        case .macos:   return "MacOSX"
        case .tvos:    return "AppleTVOS"
        case .watchos: return "WatchOS"
        }
    }
    
    public func target(bundleVersion: String) -> String? {
        switch self {
        case .ios:     return "arm64-apple-ios\(bundleVersion)"
        case .macos:   return "x86_64-macosx\(bundleVersion)"
        default: return nil
        }
    }
}

public typealias PlaygroundOutput<A>  = NEA<(page: RenderingURL, platform: Platform, output: RenderingOutput<A>)>
public typealias PlaygroundsOutput<A> = NEA<(playground: RenderingURL, output: PlaygroundOutput<A>)>
