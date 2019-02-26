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
        let expected: [Node] = [.nef(command: .hidden, [.markup(description: .some(""), "This is a hidden markup\n")]),
                                .markup(description: .some(""), "This is a visible markup multiline\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundMarkup_AndInnerNefBlock_parse_returnsMarkupNode() {
        let input = """
                    /*:
                    // nef:begin:hidden
                    This is a visible markup multiline
                    // nef:end
                     */

                    """
        let expected: [Node] = [.markup(description: .some(""), "This is a visible markup multiline\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundNefBlock_AndInnerNefBlock_parse_returnsNestedNefNodes() {
        let input = """
                    // nef:begin:hidden
                    // This is an invisible comment
                    // nef:begin:header
                    This is a header command
                    // nef:end
                    // nef:end

                    """
        let expected: [Node] = [.nef(command: .hidden, [
                                                        .block([.comment("// This is an invisible comment\n")]),
                                                        .nef(command: .header, [.raw("This is a header command\n")])
                                                       ])
                               ]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }


    //    enum Nef: Equatable {
    //        enum Command: String, Equatable {
    //            case header
    //            case hidden
    //            case invalid
    //        }
    //    }
    //
    //    case nef(command: Nef.Command, [Node])
    //    case markup(description: String?, String)
    //    case block([Code])
    //    case raw(String)


    
//
//    func testLeftDelimiterWithoutRightDelimiter_parse_returnsPlainText() {
//        // given
//        let input = "Hello *foo bar"
//        let expected: [MarkupNode] = [
//            .text("Hello "),
//            .text("*"),
//            .text("foo bar")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testDelimitersEnclosedByPunctuation_parse_returnsFormattedText() {
//        // given
//        let input = "Hello.*Foo*!"
//        let expected: [MarkupNode] = [
//            .text("Hello."),
//            .strong([
//                .text("Foo")
//                ]),
//            .text("!")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testDelimitersEnclosedByWhitespace_parse_returnsFormattedText() {
//        // given
//        let input = "Hello. *Foo* "
//        let expected: [MarkupNode] = [
//            .text("Hello. "),
//            .strong([
//                .text("Foo")
//                ]),
//            .text(" ")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testDelimitersEnclosedByNewlines_parse_returnsFormattedText() {
//        // given
//        let input = "Hello.\n*Foo*\n"
//        let expected: [MarkupNode] = [
//            .text("Hello.\n"),
//            .strong([
//                .text("Foo")
//                ]),
//            .text("\n")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testDelimitersAtBounds_parse_returnsFormattedText() {
//        // given
//        let input = "*Foo*"
//        let expected: [MarkupNode] = [
//            .strong([
//                .text("Foo")
//                ])
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testOpeningDelimiterEnclosedByDelimiters_parse_returnsFormattedText() {
//        // given
//        let input = "Hello *_world*_"
//        let expected: [MarkupNode] = [
//            .text("Hello "),
//            .strong([
//                .text("_"),
//                .text("world")
//                ]),
//            .text("_")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testIntrawordDelimiters_parse_intrawordDelimitersAreIgnored() {
//        // given
//        let input = "_1_2_3_"
//        let expected: [MarkupNode] = [
//            .emphasis([
//                .text("1"),
//                .text("_"),
//                .text("2"),
//                .text("_"),
//                .text("3")
//                ])
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//
//    func testNestedDelimiters_parse_returnsNestedMarkup() {
//        // given
//        let input = "Hello ~*_world_*~!"
//        let expected: [MarkupNode] = [
//            .text("Hello "),
//            .delete([
//                .strong([
//                    .emphasis([
//                        .text("world")
//                        ])
//                    ])
//                ]),
//            .text("!")
//        ]
//
//        // when
//        let result = MarkupParser.parse(text: input)
//
//        // then
//        XCTAssertEqual(result, expected)
//    }
//

}
