import Foundation

public struct JekyllGenerator: Render {
    let permalink: String
    
    public init(permalink: String) {
        self.permalink = permalink
    }

    public func render(content: String) -> String? {
        guard let syntax = SyntaxAnalyzer.parse(content: content) else { return nil }
        //if VERBOSE { syntax.forEach { print($0) } }
        return syntax.reduce("") { (acc, node) in acc + node.jekyll(permalink: permalink) }
    }
}

// MARK: - Jekyll definition for each node
extension Node {
    func jekyll(permalink: String) -> String {
        switch self {
        case let .nef(command, nodes):
            return command.jekyll(nodes: nodes, permalink: permalink)

        case let .markup(_, description):
            return "\n\(description)"

        case let .block(nodes):
            let nodesJekyll = nodes.map { $0.jekyll() }.joined()
            guard !nodesJekyll.isEmpty else { return "" }
            return "```swift\n\(nodesJekyll)\n```\n"
            
        case let .raw(description):
            return description
        }
    }
}

extension Node.Nef.Command {
    func jekyll(nodes: [Node], permalink: String) -> String {
        switch self {
        case .header:
            let header = nodes.map{ $0.jekyll(permalink: permalink) }.joined()
            return """
            ---
            \(header)
            permalink: \(permalink)
            ---
            """
        case .hidden:
            return ""
        case .invalid:
            fatalError("Found .invalid command in nef: \(nodes).")
        }
    }
}

extension Node.Code {
    func jekyll() -> String {
        switch self {
        case let .code(code):
            guard !code.clean([" ", "\n"]).isEmpty else { return "" }
            return code

        case let .comment(text):
            guard !text.isEmpty else { return "" }
            let comment = text.split(separator: "\n").map({ "// "+$0 }).joined(separator: "\n")
            return "\(comment)\n"
        }
    }
}
