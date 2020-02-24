//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import NefRender
import NefJekyll

import Bow
import BowEffects

public extension JekyllAPI {
    
    static func render(content: String, permalink: String) -> EnvIO<Console, nef.Error, String> {
        renderVerbose(content: content, permalink: permalink).map { info in info.rendered }^
    }
    
    static func renderVerbose(content: String, permalink: String) -> EnvIO<Console, nef.Error, (ast: String, rendered: String)> {
        NefJekyll.Jekyll()
                 .page(content: content, permalink: permalink)
                 .contramap(environment)
                 .mapError { _ in nef.Error.jekyll() }
    }
    
    static func render(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, permalink: permalink, toFile: file).map { info in info.url }^
    }
    
    static func renderVerbose(content: String, permalink: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, ast: String, rendered: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent

        return NefJekyll.Jekyll()
                        .page(content: content, permalink: permalink, filename: filename, into: output)
                        .contramap(environment)
                        .mapError { _ in nef.Error.jekyll() }
    }
    
    static func render(playground: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefJekyll.Jekyll()
                 .playground(playground, into: output)
                 .contramap(environment)
                 .mapError { _ in nef.Error.jekyll() }^
    }
    
    static func render(playgroundsAt: URL, mainPage: URL, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefJekyll.Jekyll()
                 .playgrounds(at: playgroundsAt, mainPage: mainPage, into: output)
                 .contramap(environment)
                 .mapError { _ in nef.Error.jekyll() }^
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console) -> NefJekyll.Jekyll.Environment {
        .init(console: console,
              fileSystem: MacFileSystem(),
              persistence: .init(),
              xcodePlaygroundSystem: MacXcodePlaygroundSystem(),
              jekyllPrinter: CoreRender.jekyll.render)
    }
}
