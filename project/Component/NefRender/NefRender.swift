//  Copyright © 2020 The nef Authors.

import Foundation
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
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let rendered = EnvIO<RenderEnvironment, RenderError, RendererOutput>.var()
        
        return binding(
           rendered <- self.renderPage(content: content, generator: generator),
                    |<-self.structure(step: step.increment(2), output: file.deletingLastPathComponent()),
                    |<-self.persistContent(step: step.increment(3), content: rendered.get.output, atFile: file),
        yield: (url: file, ast: rendered.get.ast, trace: rendered.get.output))^
    }
    
    public func renderPlayground(_ playground: URL, into output: URL, filename: @escaping (_ page: String) -> String, generator: @escaping (_ playground: String, _ page: String) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, RendererPlayground> {
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        let output = output.appendingPathComponent(playgroundName(playground))

        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)

        return binding(
              pages <- self.getPages(step: step.increment(1), playground: playground),
           rendered <- self.renderPages(pages: pages.get, inPlayground: playground, output: output, filename: filename, generator: generator),
        yield: RendererPlayground(playground: RendererURL(url: playground, description: self.playgroundName(playground)),
                                  pages: rendered.get.map { page in RendererURL(url: page, description: self.playgroundPageName(page)) }^))^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL, filename: @escaping (_ page: String) -> String, generator: @escaping (_ playground: String, _ page: String) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, RendererPlaygrounds> {
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<RendererPlayground>.self)
        
        return binding(
            playgrounds <- self.getPlaygrounds(step: step.increment(1), at: folder),
               rendered <- playgrounds.get.traverse { playground in self.renderPlayground(playground, into: output, filename: filename, generator: generator) }^,
        yield: RendererPlaygrounds(playgrounds: rendered.get))^
    }
    
    // MARK: - render <helpers>
    private func renderPage(page: URL, output: URL, filename: String, generator: CoreRender) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        let page = page.appendingPathComponent("Contents.swift")
        guard let content = try? String(contentsOf: page) else { return EnvIO.raiseError(.render(page: page))^ }
        
        return renderPage(content: content, atFile: file, generator: generator)
    }
    
    private func renderPages(pages: NEA<URL>, inPlayground: URL, output: URL, filename: @escaping (_ page: String) -> String, generator: @escaping (_ playground: String, _ page: String) -> CoreRender) -> EnvIO<RenderEnvironment, RenderError, NEA<URL>> {
        pages.traverse { (page: URL) in
            let playgroundName = self.playgroundName(inPlayground)
            let pageName = self.playgroundPageName(page)
            let filename = "\(filename(pageName).removeExtension).md"
            let generator = generator(playgroundName, pageName)
            
            return self.renderPage(page: page, output: output, filename: filename, generator: generator).map { $0.url }
        }^
    }
    
    // MARK: - private <helpers>
    private func playgroundName(_ playground: URL) -> String {
        playground.lastPathComponent.removeExtension.lowercased().replacingOccurrences(of: "?", with: "-")
                                                                 .replacingOccurrences(of: " ", with: "-")
    }
    
    private func playgroundPageName(_ page: URL) -> String {
        page.lastPathComponent.removeExtension.lowercased().replacingOccurrences(of: "?", with: "-")
                                                           .replacingOccurrences(of: " ", with: "-")
    }
    
    private func structure(step: Step, output: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            guard !env.fileSystem.exist(directory: output) else { return IO.pure(())^ }
            
            return binding(
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
    
    private func persistContent(step: Step, content: String, atFile file: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Rendering file '\(file.path.parentPath.filename)/\(file.path.filename)'"),
                |<-env.fileSystem.write(content: content, toFile: file).mapLeft { _ in .create(file: file) },
            yield: ())^.reportStatus(step: step, in: env.console)
        }
    }
}
