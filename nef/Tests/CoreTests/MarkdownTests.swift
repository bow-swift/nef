//  Copyright © 2019 The nef Authors.

import XCTest
@testable import Core

class MarkdownTests: XCTestCase {

    func testPlainPlaygroundWithMultiMarkup_render_returnsMarkupNodeAndStartWithNewLine() {
        let input = """
                    /*:
                     ### This is a markup
                     */

                    """
        let expected = "\n### This is a markup\n"
        let result = Markup.MarkdownGenerator().render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithMultiMarkupAndWhiteSpaces_render_returnsTrimMarkupNode() {
        let input = """
                    /*: trimming white spaces
                        ### This is a Title with spaces
                        text with spaces.

                     ## Title without spaces
                       # Title with one space.
                     */

                    """
        let expected = "\n### This is a Title with spaces\n    text with spaces.\n\n## Title without spaces\n# Title with one space.\n"
        let result = Markup.MarkdownGenerator().render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithCode_render_returnsSwiftBlock() {
        let input = """
                    import Bow

                    """
        let expected = "\n```swift\n\(input)```\n"
        let result = Markup.MarkdownGenerator().render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithNefHeader_render_returnsEmptyNode() {
        let input = """
                    // nef:begin:header
                    /*
                    layout: docs
                    title: title
                    video: video
                    */
                    // nef:end

                    """
        let expected = ""
        
        let result = Markup.MarkdownGenerator().render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithCodeAndNefHiddenBlock_render_returnsSwiftBlock() {
        let code = """
                    let nef = "It is awesone!"
                   """
        let input = """
                    // nef:begin:hidden
                    import Bow
                    // nef:end

                    \(code)

                    """
        let expected = "\n```swift\n\(code)\n```\n"
        let result = Markup.MarkdownGenerator().render(content: input)

        XCTAssertEqual(result, expected)
    }
}
