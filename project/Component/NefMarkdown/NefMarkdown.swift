//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore

import Bow
import BowEffects

public struct Markdown {
    private let generator = MarkdownGenerator()
    
    public init() {}
    
    public func renderPage(content: String) -> EnvIO<MarkdownEnvironment, MarkdownError, (rendered: String, ast: String)> {
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<MarkdownError, RendererOutput>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering markdown content"),
                rendered <- self.renderPage(step: step, generator: self.generator, content: content).provide(env),
            yield:(rendered: rendered.get.output, ast: rendered.get.ast))^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPage(content: String, filename: String, into output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        let step: Step = .init(total: 1, partial: 1, duration: .seconds(2))
        let rendered = IO<MarkdownError, RendererOutput>.var()
        
        return EnvIO { env in
            binding(
                         |<-env.console.printStep(step: step, information: "\t• Rendering markdown '\(filename)'"),
                rendered <- self.renderPage(step: step, generator: self.generator, content: content).provide(env),
                         |<-self.persistContent(rendered.get.output, atFile: file).provide(env),
            yield:(url: file, ast: rendered.get.ast, trace: rendered.get.output))^.reportStatus(step: step, in: env.console)
        }
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgroundName = playground.path.filename.removeExtension
        let output = output.appendingPathComponent(playgroundName)
        
        let pages = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var([URL].self)
        
        return binding(
              pages <- self.getPages(step: step.increment(1), playground: playground),
                    |<-self.structure(step: step.increment(2), output: output),
           rendered <- self.buildPages(step: step.increment(3), pages: pages.get, output: output),
        yield: rendered.get)^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var(NEA<URL>.self)
        let pages = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var([URL].self)
        
        return binding(
                        |<-self.structure(step: step.increment(1), output: output),
            playgrounds <- self.getPlaygrounds(step: step.increment(2), at: folder),
                  pages <- playgrounds.get.all().flatTraverse { playground in self.renderPlayground(playground, into: output) }^,
        yield: playgrounds.get.all())^
    }
    
    // MARK: steps
    private func structure(step: Step, output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Creating folder structure (\(output.path.filename))"),
                |<-env.fileSystem.createDirectory(at: output).mapLeft { _ in .structure },
            yield: ())^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func getPlaygrounds(step: Step, at folder: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, NEA<URL>> {
        EnvIO { env in
            let playgrounds = IOPartial<MarkdownError>.var(NEA<URL>.self)
            
            return binding(
                            |<-env.console.printStep(step: step, information: "Listing playgrounds in '\(folder.path.filename)'"),
                playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
            yield: playgrounds.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func getPages(step: Step, playground: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, NEA<URL>> {
        EnvIO { env in
            let pages = IOPartial<MarkdownError>.var(NEA<URL>.self)
            
            return binding(
                      |<-env.console.printStep(step: step, information: "Listing pages for '\(playground.path.filename)'"),
                pages <- env.playgroundSystem.pages(in: playground).mapLeft { _ in .getPages(folder: playground) },
            yield: pages.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    // MARK: steps <helpers>
    private func renderPage(step: Step, generator: MarkdownGenerator, content: String) -> EnvIO<MarkdownEnvironment, MarkdownError, RendererOutput> {
        EnvIO.async { callback in
            if let rendered = generator.render(content: content) {
                callback(.right(rendered))
            } else {
                callback(.left(.renderContent))
            }
        }^
    }
    
    private func persistContent(_ content: String, atFile file: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, Void> {
        EnvIO { env in
            env.fileSystem.write(content: content, toFile: file).mapLeft { _ in MarkdownError.create(file: file) }
        }^
    }
    
    private func buildPages(step: Step, pages: NEA<URL>, output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        
        func buildPage(step: Step, page: URL, generator: MarkdownGenerator, output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
            let filename = "\(page.path.filename.removeExtension).md"
            let file = output.appendingPathComponent(filename)
            let page = page.appendingPathComponent("Contents.swift")
            guard let content = try? String(contentsOf: page) else { return EnvIO.raiseError(.render(page: page))^ }
            
            let rendered = EnvIO<MarkdownEnvironment, MarkdownError, RendererOutput>.var()
            
            return binding(
                rendered <- self.renderPage(step: step, generator: self.generator, content: content),
                         |<-self.persistContent(rendered.get.output, atFile: file),
            yield: [file])^
        }
        
        return pages.all()
                    .flatTraverse { (page: URL) in
                        buildPage(step: step, page: page, generator: self.generator, output: output)
                    }^
    }
}
