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
        renderPage(content: content).flatMap(filterImagesData)^
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
            let rendered = IO<RenderError, RenderingOutput>.var()
            
            return binding(
                    continueOn(.main),
                rendered <- env.render.page(content: content).provide(env.renderEnvironment),
            yield: rendered.get)
        }
    }
    
    private func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        EnvIO { env in
            let rendered = IO<RenderError, PlaygroundOutput>.var()
            
            return binding(
                    continueOn(.main),
                rendered <- env.render.playground(playground).provide(env.renderEnvironment),
            yield: rendered.get)
        }
    }
    
    private func renderPlaygrounds(atFolder folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        EnvIO { env in
            let rendered = IO<RenderError, PlaygroundsOutput>.var()
            
            return binding(
                    continueOn(.main),
                rendered <- env.render.playgrounds(at: folder).provide(env.renderEnvironment),
            yield: rendered.get)
        }
    }
    
    // MARK: private <helper>
    private func writePages(_ pages: PlaygroundOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        pages.traverse { info in self.writePage(pagePathComponent: info.page.escapedTitle, content: info.output, output: output)^ }^
    }
    
    private func writePage(pagePathComponent: String, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        let file = output.appendingPathComponent(pagePathComponent)
        return writePage(content, atFile: file).map { _ in file }^
    }
    
    private func writePage(_ page: RenderingOutput, atFile file: URL) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { env in
            env.persistence.writePage(page, file).provide(env.fileSystem).mapError { _ in .page(file) }
        }
    }
    
    private func writePlaygrounds(_ playgrounds: PlaygroundsOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        playgrounds.traverse { info in self.writePlayground(playground: info.playground, content: info.output, output: output)^ }^
    }
    
    private func writePlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        content.traverse { info in self.writePage(pagePathComponent: "\(playground.escapedTitle)/\(info.page.escapedTitle)", content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    // MARK: private <utils>
    private func filterImagesData(_ info: RenderingOutput) -> EnvIO<Environment, RenderError, (ast: String, images: NEA<Data>)> {
        let images: [Data] = info.output.all().compactMap { image in
            switch image {
            case let .data(data): return data
            default: return nil
            }
        }
        
        return images.count > 0 ? EnvIO.pure((ast: info.ast, images: NEA.fromArrayUnsafe(images)))^
                                : EnvIO.raiseError(.content())^
    }
}
