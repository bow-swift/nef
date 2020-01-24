//  Copyright © 2019 The nef Authors.

import AppKit
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Carbon {
    public typealias Environment = RenderCarbonEnvironment<Image>
    typealias RenderingOutput = NefCommon.RenderingOutput<Image>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<Image>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<Image>
    
    public init() {}
        
    public func page(content: String) -> EnvIO<Environment, RenderError, (ast: String, images: NEA<Data>)> {
        renderPage(content: content).flatMap(flattenImagesData)^
    }
    
    public func page(content: String, filename: String, into output: URL) -> EnvIO<Environment, RenderError, (ast: String, url: URL)> {
        let file = output.appendingPathComponent(filename)
        let rendered = EnvIO<Environment, RenderError, RenderingOutput>.var()
        
        return binding(
            rendered <- self.renderPage(content: content),
                     |<-self.writePage(rendered.get, atFile: file),
        yield: (ast: rendered.get.ast, url: file))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlayground(playground),
              written <- self.writePages(rendered.get, into: output),
        yield: written.get)^
    }
    
    public func playgrounds(at folder: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlaygrounds(atFolder: folder),
              written <- self.writePlaygrounds(rendered.get, into: output),
        yield: written.get)^
    }
    
    public func request(configuration: CarbonModel) -> URLRequest {
        CarbonViewer.urlRequest(from: configuration)
    }
    
    public func view(configuration: CarbonModel) -> NefModels.CarbonView {
        CarbonWebView(code: configuration.code, state: configuration.style)
    }
    
    // MARK: private <renders>
    private func renderPage(content: String) -> EnvIO<Environment, RenderError, RenderingOutput> {
        EnvIO { env in
            env.render.page(content: content).provide(env.renderEnvironment)
        }
    }
    
    private func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        EnvIO { env in env.render.playground(playground).provide(env.renderEnvironment) }
    }
    
    private func renderPlaygrounds(atFolder folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        EnvIO { env in env.render.playgrounds(at: folder).provide(env.renderEnvironment) }
    }
    
    // MARK: private <helper>
    private func writePages(_ pages: PlaygroundOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        pages.traverse { info in self.writePage(page: info.page, content: info.output, output: output)^ }^
    }
    
    private func writePage(page: RenderingURL, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        let file = output.appendingPathComponent(page.escapedTitle)
        return writePage(content, atFile: file).map { _ in file }^
    }
    
    private func writePage(_ page: RenderingOutput, atFile file: URL) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { env in
            env.persistence.writePage(page, file).provide(env.fileSystem).mapLeft { _ in .page(file) }
        }
    }
    
    private func writePlaygrounds(_ playgrounds: PlaygroundsOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        playgrounds.traverse { info in self.writePlayground(playground: info.playground, content: info.output, output: output)^ }^
    }
    
    private func writePlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        content.traverse { info in self.writePage(page: info.page, content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    // MARK: private <utils>
    private func flattenImagesData(_ info: RenderingOutput) -> EnvIO<Environment, RenderError, (ast: String, images: NEA<Data>)> {
        info.output.traverse { image in
            switch image {
            case let .data(data): return IO.pure(data)
            default: return IO.raiseError(.content)
            }
        }^.map { images in
            (ast: info.ast, images: images)
        }^.env()
    }
}
