import XCTest
@testable import Markup

class MarkupSyntaxTests: XCTestCase {

    func testPlainPlaygroundWithCode_parse_returnsCodeNode() {
        let input = "import Bow // testing\n"
        let expected: [Node] = [.block([.code("import Bow // testing\n")])]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithSimpleComment_parse_returnsCommentNode() {
        let input = "// import Bow // testing\n"
        let expected: [Node] = [.block([.comment("// import Bow // testing\n")])]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithMultiComment_parse_returnsCommentNode() {
        let input = """
                    /*
                        import Bow // testing
                     */

                    """
        let expected: [Node] = [.block([.comment(input)])]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithSimpleMarkup_parse_returnsMarkupNode() {
        let input = "//: This is a test\n"
        let expected: [Node] = [.markup(description: nil, "This is a test\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithMultiMarkup_parse_returnsMarkupNode() {
        let input = """
                    /*:
                    This is a test
                     */

                    """
        let expected: [Node] = [.markup(description: .some(""), "This is a test\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithMultiMarkupAndDescription_parse_returnsMarkupNode() {
        let input = """
                    /*: information
                    This is a test
                     */

                    """
        let expected: [Node] = [.markup(description: .some("information"), "This is a test\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithHiddenMarkup_AndMarkup_parse_returnsNefAndMarkupNodes() {
        let input = """
                    // nef:begin:hidden
                    /*:
                    This is a hidden markup
                     */
                    // nef:end
                    /*:
                    This is a visible markup multiline
                     */

                    """
        let expected: [Node] = [.nef(command: .hidden, [.raw("This is a hidden markup\n")]),
                                .markup(description: .some(""), "This is a visible markup multiline\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundMarkup_AndNestedNefNode_parse_returnsMarkupNode() {
        let input = """
                    /*:
                    // nef:begin:hidden
                    This is a visible 👀 markup multiline ©
                    // nef:end
                     */

                    """
        let expected: [Node] = [.markup(description: .some(""), "This is a visible 👀 markup multiline ©\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundMultiComment_AndNestedNefNode_parse_returnsCommentNode() {
        let input = """
                    /*
                    // nef:begin:hidden
                    This is a visible comment multiline
                    // nef:end
                     */

                    """
        let expected: [Node] = [.block([.comment("/*\nThis is a visible comment multiline\n */\n")])]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundNef_AndNestedNef_parse_returnsNestedNefNodes() {
        let input = """
                    // nef:begin:hidden
                    // This is an invisible comment
                        // nef:begin:header
                        This is a nested header
                        // nef:end
                    // nef:end

                    """
        let expected: [Node] = [.nef(command: .hidden, [
                                                        .block([.comment("// This is an invisible comment\n")]),
                                                        .nef(command: .header, [.raw("    This is a nested header\n")])
                                                       ])
                               ]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundNefWithNestedComment_parse_returnsNefNodeWithRawChild() {
        let input = """
                    // nef:begin:hidden
                    /*
                    This is a raw comment
                    */
                    // nef:end

                    """

        let expected: [Node] = [.nef(command: .hidden, [.raw("This is a raw comment\n")])]
        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundNefWithNestedMarkup_parse_returnsNefNodeWithRawChild() {
        let input = """
                    // nef:begin:hidden
                    /*: Markup
                    This is a raw markup
                    */
                    // nef:end

                    """

        let expected: [Node] = [.nef(command: .hidden, [.raw("This is a raw markup\n")])]
        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundNefWithInvalidNestedComment_parse_returnsEmptyNodes() {
        let input = """
                    // nef:begin:hidden
                    /*
                    This is a raw comment
                    // nef:end
                    */

                    """

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, [])
    }

    func testPlainPlaygroundLeftDelimiterWithoutRightDelimiter_parse_returnsEmptyNodes() {
        let input = """
                    // nef:begin:hidden
                    This is an invisible raw line - valid
                    // nef:end

                    // nef:begin:hidden
                    This is an invisible raw line - invalid

                    """
        let expected: [Node] = []
        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundCodeWithLeadingTrailingEmptyLines_parse_returnsTrimmingBlockCode() {
        let blockCode = """
                        /*
                         This is a multi comment
                         */
                        public func add(_ a: Int, _ b: Int) -> Bool {
                            return a + b
                        }

                        """
        let input = "\n\n\n\n\n\n\(blockCode)\n\n\n"

        let expected: [Node] = [.block([.comment("/*\n This is a multi comment\n */\n"),
                                        .code("public func add(_ a: Int, _ b: Int) -> Bool {\n    return a + b\n}\n")
                                       ])
                               ]
        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundCodeWithLeadingTrailingEmptyLines_AndOtherWithoutLeadingTrailingEmptyLines_parse_returnsSameNodes() {
        let blockCode = """
                        /*
                         This is a multi comment
                         */
                        public func add(_ a: Int, _ b: Int) -> Bool {
                            return a + b
                        }

                        """
        let input = "\n\n\n\n\n\(blockCode)\n\n"

        let result = Markup.SyntaxAnalyzer.parse(content: input)
        let resultWithoutLeadingTrailingEmptyLines = Markup.SyntaxAnalyzer.parse(content: blockCode)

        XCTAssertEqual(result, resultWithoutLeadingTrailingEmptyLines)
    }

    func testPlainPlaygroundNefWithInvalidCommand_parse_returnsNefNode() {
        let input = """
                    // nef:begin:invalidCommand
                    This is a nef block
                    // nef:end

                    """
        let expected: [Node] = [.nef(command: .invalid, [.raw("This is a nef block\n")])]
        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

}
