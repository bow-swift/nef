//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

extension NodeProcessor where D == CoreJekyllEnvironment, A == String {
    static var jekyll: NodeProcessor {
        func render(node: Node) -> EnvIO<D, CoreRenderError, A> {
            EnvIO { env in
                IO.pure(node.jekyll(permalink: env.permalink))^
            }
        }
        
        func merge(nodes: [A]) -> EnvIO<D, CoreRenderError, NEA<A>> {
            let data = nodes.combineAll()
            guard !data.isEmpty else { return EnvIO.raiseError(.emptyNode)^ }
            return EnvIO.pure(NEA.of(data))^
        }
        
        return .init(render: render, merge: merge)
    }
}


// MARK: - node definition <jekyll>
extension Node {
    func jekyll(permalink: String) -> String {
        switch self {
        case let .nef(command, nodes):
            return command.jekyll(nodes: nodes, permalink: permalink)

        default:
            return markdown()
        }
    }
}

extension Node.Nef.Command {
    func jekyll(nodes: [Node], permalink: String) -> String {
        switch self {
        case .header:
            let header = nodes.map{ $0.jekyll(permalink: permalink) }.joined()
            let headerTrimmed = header.components(separatedBy: "\n").map{ $0.trimmingWhitespaces }.joined(separator: "\n")

            return """
            ---
            \(headerTrimmed)permalink: \(permalink)
            ---

            """
        case .hidden:
            return ""
        case .invalid:
            fatalError("error: found .invalid command in nef: \(nodes).")
        }
    }
}
