//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefRender
import NefJekyll

import Bow
import BowEffects

public extension JekyllAPI {
    
    static func render(content: String, permalink: String) -> EnvIO<Console, nef.Error, String> {
        renderVerbose(content: content, permalink: permalink).map { info in info.rendered }^
    }
    
    static func renderVerbose(content: String, permalink: String) -> EnvIO<Console, nef.Error, (rendered: String, ast: String)> {
        NefJekyll.Jekyll()
                 .renderPage(content: content, permalink: permalink)
                 .contramap { console in RenderEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                 .mapError { _ in nef.Error.jekyll }
    }
    
    static func render(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, permalink: permalink, toFile: file).map { info in info.url }^
    }
    
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, trace: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent
        
        return NefJekyll.Jekyll()
                        .renderPage(content: content, permalink: permalink, filename: filename, into: output)
                        .contramap { console in RenderEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                        .mapError { e in nef.Error.jekyll }^
    }
    
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        NefJekyll.Jekyll()
                 .renderPlayground(playground, into: output)
                 .contramap { console in RenderEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                 .mapError { _ in nef.Error.jekyll }^
    }
    
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        NefJekyll.Jekyll()
                 .renderPlaygrounds(at: playgroundsAt, mainPage: mainPage, into: output)
                 .contramap { console in RenderEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                 .mapError { _ in nef.Error.jekyll }^
    }
}
