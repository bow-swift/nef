//
//  MarkupTests.swift
//  MarkupTests
//
//  Created by Miguel Ángel Díaz on 22/02/2019.
//  Copyright © 2019 47 Degrees. All rights reserved.
//

import XCTest
@testable import Markup


//case nef(command: Nef.Command, [Node])
//case markup(title: String?, String)
//case comment(String)
//case code(String)
//case unknown(String)



class MarkupTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testPlainPlayground_parse_returnsCodeNode() {
        let input = "import Bow // testing\n"
        let expected: [Node] = [.code("import Bow // testing\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithSimpleMarkup_parse_returnsMarkupNode() {
        let input = "//: This is a test\n"
        let expected: [Node] = [.markup(description: nil, "This is a test\n")]

        let result = Markup.SyntaxAnalyzer.parse(content: input)

        XCTAssertEqual(result, expected)
    }
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
