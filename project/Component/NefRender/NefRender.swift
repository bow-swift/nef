//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore

import Bow
import BowEffects

public struct NefRender {
    
    public init() {}
    
    public func renderPage(content: String, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, RendererOutput> {
        EnvIO.async { callback in
            if let rendered = generator.render(content: content) {
                callback(.right(rendered))
            } else {
                callback(.left(.renderContent))
            }
        }^
    }
    
    public func renderPage(content: String, atFile file: URL, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let rendered = EnvIO<RenderEnvironment, RenderError, RendererOutput>.var()
        
        return binding(
            rendered <- self.renderPage(content: content, generator: generator),
                     |<-self.persistContent(rendered.get.output, atFile: file),
        yield: (url: file, ast: rendered.get.ast, trace: rendered.get.output))^
    }
    
    public func renderPlayground(_ playground: URL, into output: URL, generator: @escaping (_ playground: URL, _ page: URL) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgroundName = playground.path.filename.removeExtension
        let output = output.appendingPathComponent(playgroundName)
        
        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var([URL].self)
        
        return binding(
              pages <- self.getPages(step: step.increment(1), playground: playground),
                    |<-self.structure(step: step.increment(2), output: output),
           rendered <- self.renderPages(pages: pages.get, inPlayground: playground, output: output, generator: generator),
        yield: rendered.get)^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL, generator: @escaping (_ playground: URL, _ page: URL) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var([URL].self)
        
        return binding(
                        |<-self.structure(step: step.increment(1), output: output),
            playgrounds <- self.getPlaygrounds(step: step.increment(2), at: folder),
                  pages <- playgrounds.get.all().flatTraverse { playground in self.renderPlayground(playground, into: output, generator: generator) }^,
        yield: playgrounds.get.all())^
    }
    
    // MARK: - render <helpers>
    private func renderPage(page: URL, output: URL, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let filename = "\(page.path.filename.removeExtension).md"
        let file = output.appendingPathComponent(filename)
        let page = page.appendingPathComponent("Contents.swift")
        
        guard let content = try? String(contentsOf: page) else { return EnvIO.raiseError(.render(page: page))^ }
        return renderPage(content: content, atFile: file, generator: generator)
    }
    
    private func renderPages(pages: NEA<URL>, inPlayground: URL, output: URL, generator: @escaping (_ playground: URL, _ page: URL) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        pages.all().traverse { (page: URL) in
            self.renderPage(page: page, output: output, generator: generator(inPlayground, page)).map { $0.url }
        }^
    }
    
    // MARK: - private <helpers>
    private func structure(step: Step, output: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Creating folder structure (\(output.path.filename))"),
                |<-env.fileSystem.createDirectory(at: output).mapLeft { _ in .structure },
            yield: ())^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func getPlaygrounds(step: Step, at folder: URL) -> EnvIO<RenderEnvironment, RenderError, NEA<URL>> {
        EnvIO { env in
            let playgrounds = IOPartial<RenderError>.var(NEA<URL>.self)
            
            return binding(
                            |<-env.console.printStep(step: step, information: "Listing playgrounds in '\(folder.path.filename)'"),
                playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
            yield: playgrounds.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func getPages(step: Step, playground: URL) -> EnvIO<RenderEnvironment, RenderError, NEA<URL>> {
        EnvIO { env in
            let pages = IOPartial<RenderError>.var(NEA<URL>.self)
            
            return binding(
                      |<-env.console.printStep(step: step, information: "Listing pages for '\(playground.path.filename)'"),
                pages <- env.playgroundSystem.pages(in: playground).mapLeft { _ in .getPages(folder: playground) },
            yield: pages.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func persistContent(_ content: String, atFile file: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            env.fileSystem.write(content: content, toFile: file).mapLeft { _ in .create(file: file) }
        }^
    }
}
