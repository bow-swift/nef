//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore

import Bow
import BowEffects

public struct NefRender {
    
    public init() {}
    
    // MARK: - steps
    public func structure(step: Step, output: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Creating folder structure (\(output.path.filename))"),
                |<-env.fileSystem.createDirectory(at: output).mapLeft { _ in .structure },
            yield: ())^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func getPlaygrounds(step: Step, at folder: URL) -> EnvIO<RenderEnvironment, RenderError, NEA<URL>> {
        EnvIO { env in
            let playgrounds = IOPartial<RenderError>.var(NEA<URL>.self)
            
            return binding(
                            |<-env.console.printStep(step: step, information: "Listing playgrounds in '\(folder.path.filename)'"),
                playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
            yield: playgrounds.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func getPages(step: Step, playground: URL) -> EnvIO<RenderEnvironment, RenderError, NEA<URL>> {
        EnvIO { env in
            let pages = IOPartial<RenderError>.var(NEA<URL>.self)
            
            return binding(
                      |<-env.console.printStep(step: step, information: "Listing pages for '\(playground.path.filename)'"),
                pages <- env.playgroundSystem.pages(in: playground).mapLeft { _ in .getPages(folder: playground) },
            yield: pages.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    // MARK: - public helpers
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
    
    public func renderPage(page: URL, output: URL, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let filename = "\(page.path.filename.removeExtension).md"
        let file = output.appendingPathComponent(filename)
        let page = page.appendingPathComponent("Contents.swift")
        
        guard let content = try? String(contentsOf: page) else { return EnvIO.raiseError(.render(page: page))^ }
        return renderPage(content: content, atFile: file, generator: generator)
    }
    
    public func renderPages(pages: NEA<URL>, output: URL, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        pages.all().traverse { (page: URL) in
            self.renderPage(page: page, output: output, generator: generator).map { $0.url }
        }^
    }
    
    // MARK: - private helpers
    private func persistContent(_ content: String, atFile file: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            env.fileSystem.write(content: content, toFile: file).mapLeft { _ in .create(file: file) }
        }^
    }
}
