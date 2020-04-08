//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Markdown {
    public typealias Environment = RenderMarkdownEnvironment<String>
    typealias RenderingOutput = NefCommon.RenderingOutput<String>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<String>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<String>
    
    public init() {}
    
    public func page(content: String) -> EnvIO<Environment, RenderError, (ast: String, rendered: String)> {
        renderPage(content: content).map { rendered in
            (ast: rendered.ast, rendered: self.contentFrom(page: rendered))
        }^
    }

    public func page(content: String, filename: String, into output: URL) -> EnvIO<Environment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        let rendered = EnvIO<Environment, RenderError, RenderingOutput>.var()
        
        return binding(
            rendered <- self.renderPage(content: content),
                     |<-self.write(page: rendered.get, into: file),
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlayground(playground),
              written <- self.writePages(rendered.get, into: output),
        yield: written.get)^
    }
    
    public func playgrounds(atFolder folder: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlaygrounds(atFolder: folder),
              written <- self.writePlaygrounds(rendered.get, into: output),
        yield: written.get)^
    }
    
    // MARK: private <helpers>
    private func writePages(_ pages: PlaygroundOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        pages.traverse { info in self.writePage(page: info.page, content: info.output, output: output)^ }^
    }
    
    private func writePage(page: RenderingURL, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        writePage(pathComponent: page.escapedTitle, content: content, output: output)
    }
    
    private func writePage(pathComponent: String, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(pathComponent).appendingPathExtension("md")
            return env.persistence.writePage(content, file).provide(env.fileSystem)
                                  .map { _ in file }^.mapError { _ in .page(file) }
        }^
    }
    
    private func writePlaygrounds(_ playgrounds: PlaygroundsOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        playgrounds.traverse { info in self.writePlayground(playground: info.playground, content: info.output, output: output)^ }^
    }
    
    private func writePlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        content.traverse { info -> EnvIO<Environment, RenderError, URL> in
            let pathComponent = RenderEnvironmentInfo.info(playground: playground, page: info.page).pathComponent
            return self.writePage(pathComponent: !pathComponent.isEmpty ? pathComponent : info.page.escapedTitle,
                                  content: info.output,
                                  output: output)
        }.map { _ in playground.url }^
    }
    
    private func write(page: RenderingOutput, into file: URL) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { env in
            env.persistence.writePage(page, file).provide(env.fileSystem).mapError { _ in .page(file) }
        }
    }
    
    // MARK: private <renders>
    private func renderPage(content: String) -> EnvIO<Environment, RenderError, RenderingOutput> {
        EnvIO { env in env.render.page(content: content).provide(env.renderEnvironment) }
    }
    
    private func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        EnvIO { env in env.render.playground(playground).provide(env.renderEnvironment) }
    }
    
    private func renderPlaygrounds(atFolder folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        EnvIO { env in env.render.playgrounds(at: folder).provide(env.renderEnvironment) }
    }
    
    // MARK: private <utils>
    private func contentFrom(page: RenderingOutput) -> String {
        page.output.all().joined()
    }
}

private extension URL {
    func appendingPlaygroundName(_ playground: URL) -> URL {
        appendingPathComponent(playground.path.filename.removeExtension)
    }
}
