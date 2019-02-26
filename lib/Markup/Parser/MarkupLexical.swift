import Foundation

struct LexicalAnalyzer {
    private let content: String
    private let currentIndex: Int

    let token: Token
    let line: String

    init?(content: String) {
        self.init(content: content, position: 0)
    }

    private init?(content: String, position: Int) {
        guard let (token, line, range) = LexicalAnalyzer.nextToken(content: content, from: position) else { return nil }

        self.content = content
        self.currentIndex = position + range.location + range.length
        self.token = token
        self.line = line
    }

    func scan() -> LexicalAnalyzer? {
        return LexicalAnalyzer(content: content, position: currentIndex)
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
            let description = markupBegin.ouput.clean("/*:", "\n").trimmingWhitespaces
            return Token.markupBegin(description: description)
        }
        if let _ = line.substring(pattern: Regex.markup) {
            return Token.markup
        }
        if let _ = line.substring(pattern: Regex.comment) {
            return Token.comment
        }
        if let _ = line.substring(pattern: Regex.multiComment.begin) {
            return Token.commentBegin(delimiter: line)
        }
        if let _ = line.substring(pattern: Regex.markupComment.end) {
            return Token.markupCommentEnd(delimiter: line)
        }

        return Token.line(line)
    }

    private static func nextToken(content: String, from index: Int) -> (token: Token, line: String, range: NSRange)? {
        guard let line = nextLine(content: content, from: index) else { return nil }
        let token = LexicalAnalyzer.token(inLine: line.ouput)
        let output = token == .markup ? line.ouput.clean("//:").trimmingWhitespaces : line.ouput

        return (token, output, line.range)
    }

    private static func nextLine(content: String, from index: Int) -> SubstringType? {
        return content.advance(index).substring(pattern: Regex.line)
    }
}


// MARK: token definition for lexical analysis

enum Token: Equatable {
    case nefBegin(command: Node.Nef.Command)
    case nefEnd
    case markupBegin(description: String)
    case markup
    case comment
    case commentBegin(delimiter: String)
    case markupCommentEnd(delimiter: String)
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
