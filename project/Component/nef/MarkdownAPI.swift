//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefMarkdown

import Bow
import BowEffects

public extension MarkdownAPI {
    
    static func render(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, toFile: file).map { info in info.url }^
    }
    
    static func renderVerbose(content: String, toFile file: URL) -> EnvIO<Console, nef.Error, (url: URL, tree: String, trace: String)> {
        let output = URL(fileURLWithPath: file.path.parentPath, isDirectory: true)
        let filename = file.pathExtension == "md" ? file.lastPathComponent : file.appendingPathExtension("md").lastPathComponent
        
        return NefMarkdown.Markdown(output: output)
                   .buildPage(content: content, filename: filename)
                   .contramap { console in MarkdownEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                   .mapError { e in nef.Error.markdown }^
    }
    
    static func render(playground: URL, in output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        NefMarkdown.Markdown(output: output)
                   .buildPlayground(playground)
                   .contramap { console in MarkdownEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                   .mapError { _ in nef.Error.markdown }^
    }
    
    static func render(playgroundsAt folder: URL, in output: URL) -> EnvIO<Console, nef.Error, [URL]> {
        NefMarkdown.Markdown(output: output)
                   .buildPlaygrounds(at: folder)
                   .contramap { console in MarkdownEnvironment(console: console, playgroundSystem: MacPlaygroundSystem(), fileSystem: MacFileSystem()) }
                   .mapError { _ in nef.Error.markdown }^
    }
}
