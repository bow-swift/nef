//  Copyright © 2019 The nef Authors.

import XCTest
@testable import NefCore

class MarkdownTests: XCTestCase {

    func testPlainPlaygroundWithMultiMarkup_render_returnsMarkupNodeAndStartWithNewLine() {
        let input = """
                    /*:
                     ### This is a markup
                     */
                    """
        let expected = "\n### This is a markup\n"
        
        assert(markdown(content: input),
               succeeds: expected)
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
        
        assert(markdown(content: input),
               succeeds: expected)
    }

    func testPlainPlaygroundWithCode_render_returnsSwiftBlock() {
        let input = """
                    import Bow
                    """
        let expected = "\n```swift\n\(input)\n```\n"
        assert(markdown(content: input), succeeds: expected)
    }

    func testPlainPlaygroundWithNefHeader_render_failsEmpty() {
        let input = """
                    // nef:begin:header
                    /*
                    layout: docs
                    title: title
                    video: video
                    */
                    // nef:end
                    """
        
        assert(markdown(content: input),
               fails: .renderEmpty)
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
        
        assert(markdown(content: input),
               succeeds: expected)
    }
    
    func testPlainPlaygroundWithCommentMultine_render_returnsCommentBlock() {
        let input =  """
                     /* Comment */
                     """
        let expected =  """

                        ```swift
                        /* Comment */
                        ```

                        """
        
        assert(markdown(content: input),
               succeeds: expected)
    }
}
