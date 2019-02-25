import Foundation

struct SyntaxAnalyzer {

    static func parse(content: String) -> [Node]? {
        var parser = SyntaxAnalyzer(content: content)
        let syntax = parser.parse()

        return syntax.contains(Node.raw("")) || !parser.openingDelimiters.isEmpty ? nil : syntax.reduce()
    }

    private var tokenizer: LexicalAnalyzer
    private var openingDelimiters: [Token]

    private init(content: String) {
        tokenizer = LexicalAnalyzer(content: content)
        openingDelimiters = []
    }

    private mutating func parse() -> [Node] {
        var nodes = [Node]()

        while let (token, line) = tokenizer.nextToken() {
            if token.isLeftDelimiter {
                openingDelimiters.append(token)
                nodes += parse()
            }
            else if let lastToken = openingDelimiters.last, token.isRightDelimiter(lastToken) {
                openingDelimiters.removeLast()
                return [node(for: nodes, parentToken: lastToken)]
            }
            else {
                nodes += [node(for: token, withLine: line)]
            }
        }

        return nodes
    }

    private func node(for token: Token, withLine line: String) -> Node {
        switch token {
        case .markup:
            return .markup(description: nil, line)
        case .comment:
            return .block([.comment(line)])
        default:
            return openingDelimiters.isEmpty ? .block([.code(line)]) : .raw(line.trimmingWhitespaces)
        }
    }

    private func node(for childrens: [Node], parentToken parent: Token) -> Node {
        let content = childrens.map { $0.string }.joined()

        switch parent {
        case let .nefBegin(command):
            return .nef(command: command, childrens)
        case let .markupBegin(description):
            return .markup(description: description, content)
        case .commentBegin:
            return openingDelimiters.isEmpty ? .block([.comment(content)]) : .raw(content)
        default:
            fatalError("Parent token [\(parent)]: not supported.")
        }
    }
}

// MARK: Helpers
extension Node {
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
}

extension Node.Code {
    var isComment: Bool {
        switch self {
        case .comment: return true
        default: return false
        }
    }
}

extension Node {
    var string: String {
        switch self {
        case let .nef(_, nodes): return nodes.map { $0.string }.joined()
        case let .markup(_, text): return text
        case let .block(nodes): return nodes.map { $0.string }.joined()
        case let .raw(line): return line
        }
    }
}

extension Node.Code {
    var string: String {
        switch self {
        case let .code(code): return code
        case let .comment(lines): return lines
        }
    }
}
