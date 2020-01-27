//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

extension NodeProcessor where D == CoreCodeEnvironment, A == String {
    static var code: NodeProcessor {
        func render(node: Node) -> EnvIO<D, CoreRenderError, A> {
            node.code().env()
        }
        
        func merge(nodes: [A]) -> EnvIO<D, CoreRenderError, NEA<A>> {
            let data = nodes.combineAll()
            return EnvIO.pure(NEA.of(data))^
        }
        
        return .init(render: render, merge: merge)
    }
}


// MARK: - node definition <carbon>
extension Node {
    func code() -> IO<CoreRenderError, String> {
        switch self {
        case let .block(nodes):
            let code = nodes.map { $0.code }.joined()
            return IO.pure(code)^
            
        default:
            return IO.pure("")^
        }
    }
}

extension Node.Code {
    var code: String {
        switch self {
        case let .code(code): return code
        default: return ""
        }
    }
}
