import XCTest
@testable import Markup

class MarkupJekyllTests: XCTestCase {

    func testPlainPlaygroundWithMultiMarkup_parse_returnsMarkupNodeAndStartWithNewLine() {
        let input = """
                    /*:
                     ### This is a markup
                     */

                    """
        let expected = "\n### This is a markup\n"
        let result = Markup.JekyllGenerator(permalink: "").render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithMultiMarkupAndWhiteSpaces_parse_returnsTrimMarkupNode() {
        let input = """
                    /*: trimming white spaces
                        ### This is a Title with spaces
                        text with spaces.

                     ## Title without spaces
                       # Title with one space.
                     */

                    """
        let expected = "\n### This is a Title with spaces\n    text with spaces.\n\n## Title without spaces\n# Title with one space.\n"
        let result = Markup.JekyllGenerator(permalink: "").render(content: input)

        XCTAssertEqual(result, expected)
    }
}
