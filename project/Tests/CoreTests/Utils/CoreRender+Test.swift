//  Copyright © 2020 The nef Authors.

import XCTest
import NefCore
import NefCommon
import NefModels

import Bow
import BowEffects


extension XCTestCase {
    func markdown(content: String) -> IO<CoreRenderError, RenderingOutput<String>> {
        CoreRender.markdown.render(content: content)
                           .provide(CoreMarkdownEnvironment())
    }
    
    func jekyll(content: String, permalink: String) -> IO<CoreRenderError, RenderingOutput<String>> {
        CoreRender.jekyll.render(content: content)
                         .provide(CoreJekyllEnvironment(permalink: permalink))
    }
    
    func carbon(content: String, downloader: CarbonDownloader, style: CarbonStyle) -> IO<CoreRenderError, RenderingOutput<Image>> {
        CoreRender.carbon.render(content: content)
                         .provide(CoreCarbonEnvironment(downloader: downloader, style: style))
    }
}


extension XCTestCase {
    func assert<A: Equatable>(_ io: IO<CoreRenderError, RenderingOutput<A>>, succeeds: A, message: String = "", file: StaticString = #file, line: UInt = #line) {
        _ = io.unsafeRunSyncEither().bimap({ e in XCTFail("\(e.localizedDescription)\(message.isEmpty ? "" : ": \(message)")", file: file, line: line) },
                                           { rendered in XCTAssertEqual(rendered.output.all().first!, succeeds, message, file: file, line: line) })
    }
    
    func assert<A: Equatable>(_ io: IO<CoreRenderError, RenderingOutput<A>>, fails: CoreRenderError, message: String = "", file: StaticString = #file, line: UInt = #line) {
        _ = io.unsafeRunSyncEither().bimap({ e in XCTAssertEqual(e, fails, message, file: file, line: line) },
                                           { rendered in XCTFail("\(rendered.output)\(message.isEmpty ? "" : ": \(message)")", file: file, line: line) })
    }
}
