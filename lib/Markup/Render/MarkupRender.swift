import Foundation

public protocol Render {
    func render(content: String) -> String?
}

protocol Jekyll {
    func jekyll(permalink: String) -> String
}

protocol Markdown {
    func markdown() -> String
}

// Dependencies
extension Node: Jekyll {}
extension Node: Markdown {}

// MARK: - default Render :: render(content:)
protocol InternalRender: Render {
    func render(node: Node) -> String
}

extension InternalRender {
    public func render(content: String) -> String? {
        let syntaxTree = SyntaxAnalyzer.parse(content: content)
        guard syntaxTree.count > 0 else { return nil }

        let filteredSyntaxTree = syntaxTree.filter { !$0.isHidden }.reduce()
        filteredSyntaxTree.forEach { print($0) }
        return filteredSyntaxTree.reduce("") { (acc, node) in acc + self.render(node: node) }
    }
}
