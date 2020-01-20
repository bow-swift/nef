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


public extension RenderingOutput {
    typealias PageOutput  = RenderingOutput<A>
    typealias PlaygroundOutput  = NEA<(page: RenderingURL, output: PageOutput)>
    typealias PlaygroundsOutput = NEA<(playground: RenderingURL, output: PlaygroundOutput)>
}
