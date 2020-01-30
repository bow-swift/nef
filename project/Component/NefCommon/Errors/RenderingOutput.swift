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
    
    public init?(platform: String) {
        guard let platform = Platform(rawValue: platform) else { return nil }
        self = platform
    }
}

public typealias PlaygroundOutput<A>  = NEA<(page: RenderingURL, platform: Platform, output: RenderingOutput<A>)>
public typealias PlaygroundsOutput<A> = NEA<(playground: RenderingURL, output: PlaygroundOutput<A>)>
