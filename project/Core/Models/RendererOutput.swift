//  Copyright © 2019 The nef Authors.

import Foundation
import Bow

public struct RendererOutput<A> {
    public let ast: String
    public let output: NEA<A>
    
    public init(ast: String, output: NEA<A>) {
        self.ast = ast
        self.output = output
    }
}
