import Foundation

struct LexicalAnalyzer {
    private let content: String
    private var currentIndex: Int

    init(content: String) {
        self.content = content
        self.currentIndex = 0
    }

    mutating func nextToken() -> (token: Token, line: String)? {
        guard let line = nextLine() else { return nil }

        let token = LexicalAnalyzer.token(inLine: line.ouput)
        let output: String
        switch token {
        case .markup:  output = line.ouput.clean(["//:"]).trimmingWhitespaces
        case .comment: output = line.ouput.clean(["//"]).trimmingWhitespaces
        default: output = line.ouput
        }

        currentIndex += line.range.location + line.range.length

        return (token, output)
    }

    // MARK: helpers
    private enum Regex {
        static let nef = (begin: "//[ ]*nef:begin:[a-z]+\n", end: "//[ ]*nef:end[ ]*\n")
        static let multiMarkup = (begin: "/\\*:.*\n")
        static let markup = "^[ ]*//:.*\n"
        static let comment = "^[ ]*//.*\n"
        static let multiComment = (begin: "/\\*.*\n")
        static let markupComment = (end: "\\*/\n")
        static let line = ".*\n"
    }

    private static func token(inLine line: String) -> Token {
        if let nefBegin = line.substring(pattern: Regex.nef.begin) {
            let command = Node.Nef.Command.get(in: nefBegin.ouput)
            return Token.nefBegin(command: command)
        }
        if let _ = line.substring(pattern: Regex.nef.end) {
            return Token.nefEnd
        }
        if let markupBegin = line.substring(pattern: Regex.multiMarkup.begin) {
            let description = markupBegin.ouput.clean(["\n"]).components(separatedBy: "/*:").last?.trimmingWhitespaces
            return Token.markupBegin(description: description ?? "")
        }
        if let _ = line.substring(pattern: Regex.markup) {
            return Token.markup
        }
        if let _ = line.substring(pattern: Regex.comment) {
            return Token.comment
        }
        if let _ = line.substring(pattern: Regex.multiComment.begin) {
            return Token.commentBegin
        }
        if let _ = line.substring(pattern: Regex.markupComment.end) {
            return Token.markupCommentEnd
        }

        return Token.line(line)
    }

    private func nextLine() -> SubstringType? {
        return content.advance(currentIndex).substring(pattern: Regex.line)
    }
}


// MARK: token definition for lexical analysis

enum Token: Equatable {
    case nefBegin(command: Node.Nef.Command)
    case nefEnd
    case markupBegin(description: String)
    case markup
    case comment
    case commentBegin
    case markupCommentEnd
    case line(String)

    func isRightDelimiter(_ token: Token) -> Bool {
        switch (token, self) {
        case (.nefBegin, .nefEnd): return true
        case (.markupBegin, .markupCommentEnd): return true
        case (.commentBegin, .markupCommentEnd): return true
        default:
            return false
        }
    }

    var isLeftDelimiter: Bool {
        switch self {
        case .nefBegin: return true
        case .markupBegin: return true
        case .commentBegin: return true
        default:
            return false
        }
    }

    var isDelimiter: Bool {
        switch self {
        case .comment: return false
        case .line: return false
        default:
            return true
        }
    }
}
