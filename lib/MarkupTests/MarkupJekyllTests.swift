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

    func testPlainPlaygroundWithCode_parse_returnsSwiftBlock() {
        let input = """
                    import Bow

                    """
        let expected = "\n```swift\n\(input)```\n"
        let result = Markup.JekyllGenerator(permalink: "").render(content: input)

        XCTAssertEqual(result, expected)
    }

    func testPlainPlaygroundWithNefHeader_parse_returnsHeaderBlock() {
        let input = """
                    // nef:begin:header
                    /*
                    layout: docs
                    title: title
                    video: video
                    */
                    // nef:end

                    """
        let expected = """
                       ---
                       layout: docs
                       title: title
                       video: video
                       permalink: permalink
                       ---

                       """

        let result = Markup.JekyllGenerator(permalink: "permalink").render(content: input)

        XCTAssertEqual(result, expected)
    }

}
