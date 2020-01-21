//  Copyright © 2020 The nef Authors.

import XCTest
import NefModels
import Bow
import BowEffects


extension XCTestCase {
    func markdown(content: String) -> IO<CoreRenderError, RendererOutput<String>> {
        CoreRender.markdown.render(content: content)
                           .provide(CoreMarkdownEnvironment())
    }
    
    func jekyll(content: String, permalink: String) -> IO<CoreRenderError, RendererOutput<String>> {
        CoreRender.jekyll.render(content: content)
                         .provide(CoreJekyllEnvironment(permalink: permalink))
    }
    
    func carbon(content: String, downloader: CarbonDownloader, style: CarbonStyle) -> IO<CoreRenderError, RendererOutput<Image>> {
        CoreRender.carbon.render(content: content)
                         .provide(CoreCarbonEnvironment(downloader: downloader, style: style))
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
