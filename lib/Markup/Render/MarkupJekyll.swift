import Foundation

public struct JekyllGenerator: InternalRender {
    let permalink: String
    
    public init(permalink: String) {
        self.permalink = permalink
    }

    func render(node: Node) -> String {
        return node.jekyll(permalink: permalink)
    }
}

// MARK: - Jekyll definition for each node
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
            fatalError("Found .invalid command in nef: \(nodes).")
        }
    }
}
