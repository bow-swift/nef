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
//extension Node: Markdown {}

// MARK: - default Render :: render(content:)
extension Render {

    public func render(content: String) -> String? {
        let syntaxTree = SyntaxAnalyzer.parse(content: content)
        guard syntaxTree.count > 0 else { return nil }

        let filteredSyntaxTree = syntaxTree.filter { !$0.isHidden }.reduce()
        filteredSyntaxTree.forEach { print($0) }
        return filteredSyntaxTree.reduce("") { (acc, node) in acc + render(node: node) }
    }

    func render(node: Node) -> String {
        return ""
    }
}
