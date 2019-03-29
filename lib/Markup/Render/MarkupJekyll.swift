import Foundation

public struct JekyllGenerator: Render {
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

        case let .markup(_, text):
            let textJekyll = text.components(separatedBy: "\n").map { line in
                guard (line.substring(pattern: "^[ ]*[#]+.*") != nil) else { return line }
                return line.trimmingLeftWhitespaces
            }.joined(separator: "\n")

            return "\n\(textJekyll)"

        case let .block(nodes):
            let nodesJekyll = nodes.map { $0.jekyll() }.joined()
            guard !nodesJekyll.isEmpty else { return "" }
            return "\n```swift\n\(nodesJekyll)```\n"
            
        case let .raw(description):
            return description
        }
    }

    var isHidden: Bool {
        switch self {
        case let .nef(command, _): return command == .hidden
        default: return false
        }
    }
}

private extension Node.Nef.Command {
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

private extension Node.Code {
    func jekyll() -> String {
        switch self {
        case let .code(code):
            return code

        case let .comment(text):
            guard !text.clean(" ", "\n").isEmpty else { return "" }
            return text
        }
    }
}
