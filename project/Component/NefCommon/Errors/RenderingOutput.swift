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


public typealias PlaygroundOutput<A>  = NEA<(page: RenderingURL, output: RenderingOutput<A>)>
public typealias PlaygroundsOutput<A> = NEA<(playground: RenderingURL, output: PlaygroundOutput<A>)>
