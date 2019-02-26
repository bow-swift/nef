import Foundation

struct SyntaxAnalyzer {

    static func parse(content: String) -> [Node] {
        let parser = SyntaxAnalyzer(content: content)
        var tokenizer = LexicalAnalyzer(content: parser.content)
        let syntax = parser.parse(tokenizer: &tokenizer)

        return syntax.contains { $0.isRaw } ? [] : syntax.reduce()
    }

    private let content: String
    private init(content: String) {
        self.content = content
    }

    private func parse(tokenizer: inout LexicalAnalyzer?, openingDelimiters: [Token] = []) -> [Node] {
        var nodes = [Node]()

        while let token = tokenizer?.token, let line = tokenizer?.line {
            tokenizer = tokenizer?.scan()

            if token.isLeftDelimiter {
                nodes += parse(tokenizer: &tokenizer, openingDelimiters: openingDelimiters + [token])
            }
            else if let lastToken = openingDelimiters.last, token.isRightDelimiter(lastToken) {
                var openingDelimiters = openingDelimiters
                _ = openingDelimiters.popLast()
                return [node(for: nodes, openDelimiter: lastToken, closeDelimiter: token, openingDelimiters: openingDelimiters)]
            }
            else {
                nodes += [node(for: token, withLine: line, openingDelimiters: openingDelimiters)]
            }
        }

        return openingDelimiters.isEmpty ? nodes : []
    }

    private func node(for token: Token, withLine line: String, openingDelimiters: [Token]) -> Node {
        switch token {
        case .markup:
            return .markup(description: nil, line)
        case .comment:
            return .block([.comment(line)])
        default:
            return openingDelimiters.isEmpty ? .block([.code(line)]) : .raw(line)
        }
    }

    private func node(for childrens: [Node], openDelimiter: Token, closeDelimiter: Token, openingDelimiters: [Token]) -> Node {
        let content = childrens.map { $0.string }.joined()

        switch (openDelimiter, closeDelimiter) {
        case let (.nefBegin(command), _):
            return .nef(command: command, childrens)

        case let (.markupBegin(description), _):
            return .markup(description: description, content)

        case let (.commentBegin(open), .markupCommentEnd(close)):
            return openingDelimiters.isEmpty ? .block([.comment("\(open)\(content)\(close)")]) : .raw(content)
        default:
            fatalError("[!] wrong block \(openDelimiter) <-> \(closeDelimiter)")
        }
    }
}

// MARK: Helpers
private extension Node {
    var string: String {
        switch self {
        case let .nef(_, nodes): return nodes.map { $0.string }.joined()
        case let .markup(_, text): return text
        case let .block(nodes): return nodes.map { $0.string }.joined()
        case let .raw(line): return line
        }
    }

    var isComment: Bool {
        switch self {
        case let .block(nodes):
            return nodes.reduce(true) { acc, node in
                acc && node.isComment
            }
        default:
            return false
        }
    }

    var isRaw: Bool {
        switch self {
        case .raw: return true
        default: return false
        }
    }
}

private extension Node.Code {
    var string: String {
        switch self {
        case let .code(code): return code
        case let .comment(lines): return lines
        }
    }

    var isComment: Bool {
        switch self {
        case .comment: return true
        default: return false
        }
    }
}
