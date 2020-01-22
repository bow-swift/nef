//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import NefRender
import NefJekyll

import Bow
import BowEffects

public extension JekyllAPI {
    
    // MARK: api <EnvIO>
    static func render(content: String, permalink: String) -> EnvIO<Console, nef.Error, String> {
        renderVerbose(content: content, permalink: permalink).map { info in info.rendered }^
    }
    
    static func renderVerbose(content: String, permalink: String) -> EnvIO<Console, nef.Error, (rendered: String, ast: String)> {
        fatalError()
//        NefJekyll.Jekyll()
//                 .renderPage(content: content, permalink: permalink)
//                 .contramap(environment)
//                 .mapError { _ in nef.Error.jekyll }
    }
    
    static func render(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, permalink: permalink, toFile: file).map { info in info.url }^
    }
    
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, trace: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent

        fatalError()
//        return NefJekyll.Jekyll()
//                        .renderPage(content: content, permalink: permalink, filename: filename, into: output)
//                        .contramap(environment)
//                        .mapError { e in nef.Error.jekyll }^
    }
    
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        fatalError()
//        NefJekyll.Jekyll()
//                 .renderPlayground(playground, into: output)
//                 .contramap(environment)
//                 .mapError { _ in nef.Error.jekyll }^
    }
    
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        fatalError()
//        NefJekyll.Jekyll()
//                 .renderPlaygrounds(at: playgroundsAt, mainPage: mainPage, into: output)
//                 .contramap(environment)
//                 .mapError { _ in nef.Error.jekyll }^
    }
    
    // MARK: api <IO>
    static func render(content: String, permalink: String) -> IO<nef.Error, String> {
        render(content: content, permalink: permalink).provide(MacDummyConsole())
    }
    
    static func renderVerbose(content: String, permalink: String) -> IO<nef.Error, (rendered: String, ast: String)> {
        renderVerbose(content: content, permalink: permalink).provide(MacDummyConsole())
    }
    
    static func render(content: String, permalink: String, toFile file: URL) -> IO<nef.Error, URL> {
        render(content: content, permalink: permalink, toFile: file).provide(MacDummyConsole())
    }
    
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> IO<nef.Error, (url: URL, ast: String, trace: String)> {
        renderVerbose(content: content, permalink: permalink, toFile: file).provide(MacDummyConsole())
    }
    
    static func render(playground: URL, into output: URL) -> IO<nef.Error, [URL]> {
        render(playground: playground, into: output).provide(MacDummyConsole())
    }
    
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> IO<nef.Error, [URL]> {
        render(playgroundsAt: playgroundsAt, mainPage: mainPage, into: output).provide(MacDummyConsole())
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> RenderJekyllEnvironment<String> {
        .init(console: console,
              fileSystem: MacFileSystem(),
              renderSystem: .init(),
              playgroundSystem: MacPlaygroundSystem(),
              jekyllPrinter: { permalink in { content in CoreRender.jekyll.render(content: content).provide(.init(permalink: permalink)) }})
    }
}
