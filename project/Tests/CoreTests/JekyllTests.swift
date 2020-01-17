//  Copyright © 2019 The nef Authors.

import XCTest
@testable import NefCore
import AppKit
import Bow
import BowEffects
import NefModels

extension XCTestCase {
    func markdown(content: String) -> IO<CoreRenderError, RendererOutput<String>> {
        CoreRender.markdown.render(content: content)
                           .provide(CoreMarkdownEnvironment())
    }
    
    func jekyll(content: String, permalink: String) -> IO<CoreRenderError, RendererOutput<String>> {
        CoreRender.jekyll.render(content: content)
                         .provide(CoreJekyllEnvironment(permalink: permalink))
    }
    
    func carbon(content: String, downloader: CarbonDownloader, style: CarbonStyle) -> IO<CoreRenderError, RendererOutput<NSImage>> {
        CoreRender.carbon.render(content: content)
                         .provide(CoreCarbonEnvironment.init(downloader: downloader, style: style))
    }
}

extension XCTestCase {
    func assert<A: Equatable>(_ io: IO<CoreRenderError, RendererOutput<A>>, succeeds: A) {
        _ = io.unsafeRunSyncEither().bimap({ e in XCTFail(e.localizedDescription) },
                                           { rendered in XCTAssertEqual(rendered.output.all().first!, succeeds) })
    }
    
    func assert<A: Equatable>(_ io: IO<CoreRenderError, RendererOutput<A>>, fails: CoreRenderError) {
        _ = io.unsafeRunSyncEither().bimap({ e in XCTAssertEqual(e, fails) },
                                           { rendered in XCTFail("\(rendered.output)") })
    }
}


class JekyllTests: XCTestCase {
    
    func testPlainPlaygroundWithMultiMarkup_render_returnsMarkupNodeAndStartWithNewLine() {
        let input = """
                    /*:
                     ### This is a markup
                     */

                    """
        
        assert(jekyll(content: input, permalink: ""),
               succeeds: "\n### This is a markup\n")
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
        
        assert(jekyll(content: input, permalink: ""),
               succeeds: expected)
    }

    func testPlainPlaygroundWithCode_render_returnsSwiftBlock() {
        let input = """
                    import Bow

                    """
        let expected = "\n```swift\n\(input)```\n"
        
        assert(jekyll(content: input, permalink: ""),
               succeeds: expected)
    }

    func testPlainPlaygroundWithNefHeader_render_returnsHeaderBlock() {
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

        assert(jekyll(content: input, permalink: "permalink"),
               succeeds: expected)
    }

    func testPlainPlaygroundWithNefHeaderAndWhitespaces_render_returnsHeaderBlockTrimmed() {
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

        
        assert(jekyll(content: input, permalink: "permalink"),
               succeeds: expected)
    }
    
}
