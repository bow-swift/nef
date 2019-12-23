//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels
import NefCore

import Bow
import BowEffects

public struct Markdown {
    private let output: URL
    private let generator = MarkdownGenerator()
    
    public init(output: URL) {
        self.output = output
    }
    
    public func buildPage(content: String, filename: String) -> EnvIO<MarkdownEnvironment, MarkdownError, (url: URL, tree: String, trace: String)> {
        let renderer = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var((tree: String, out: String).self)
        let file = self.output.appendingPathComponent(filename)
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        
        return binding(
            renderer <- self.renderPage(step: step.increment(1), generator: self.generator, filename: filename, content: content).contramap(\MarkdownEnvironment.console),
                     |<-self.persistContent(step: step.increment(2), content: renderer.get.out, atFile: file),
        yield: (url: file, tree: renderer.get.tree, trace: renderer.get.out))^
    }
    
    public func build(playground: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        let pages = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var(NEA<URL>.self)
        
        return binding(
            pages <- self.getPages(step: step.increment(1), playground: playground),
                  |<-self.buildPages(step: step.increment(2), pages: pages.get),
        yield: pages.get.all())^
    }
    
    public func buildPlaygrounds(at folder: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<MarkdownEnvironment, MarkdownError>.var(NEA<URL>.self)
        
        return binding(
                        |<-self.structure(step: step.increment(1), output: self.output),
            playgrounds <- self.getPlaygrounds(step: step.increment(2), at: folder),
                        |<-self.buildPlaygrounds(step: step.increment(3), playgrounds: playgrounds.get),
        yield: playgrounds.get.all())^
    }
    
    // MARK: steps
    private func renderPage(step: Step, generator: MarkdownGenerator, filename: String, content: String) -> EnvIO<Console, MarkdownError, (tree: String, out: String)> {
        func renderPage(generator: MarkdownGenerator, content: String) -> IO<MarkdownError, RendererOutput> {
            IO.async { callback in
                if let rendered = self.generator.render(content: content) {
                    callback(.right(rendered))
                } else {
                    callback(.left(.renderPage))
                }
            }^
        }
        
        return EnvIO { console in
            let renderer = IOPartial<MarkdownError>.var(RendererOutput.self)
            
            return binding(
                       |<-console.printStep(step: step, information: "Render markdown (\(filename))"),
              renderer <- renderPage(generator: generator, content: content),
            yield: (tree: renderer.get.tree, out: renderer.get.output))^.reportStatus(step: step, in: console)
        }^
    }
    
    private func persistContent(step: Step, content: String, atFile file: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, Void> {
        EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Writting content in file '\(file.path.filename)'"),
                |<-env.fileSystem.write(content: content, toFile: file).mapLeft { _ in MarkdownError.create(file: file) },
            yield: ())^.reportStatus(step: step, in: env.console)
        }^
    }
    
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
                playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .renderPage },
            yield: playgrounds.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func getPages(step: Step, playground: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, NEA<URL>> {
        EnvIO { env in
            let pages = IOPartial<MarkdownError>.var(NEA<URL>.self)
            
            return binding(
                      |<-env.console.printStep(step: step, information: "Listing pages in '\(playground.path.filename)'"),
                pages <- env.playgroundSystem.pages(in: playground).mapLeft { _ in .renderPage },
            yield: pages.get)^.reportStatus(step: step, in: env.console)
        }
    }
    
    // MARK: steps <helpers>
    private func buildPlaygrounds(step: Step, playgrounds: NEA<URL>) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        playgrounds.all().parFlatTraverse(build)^
    }
    
    private func buildPages(step: Step, pages: NEA<URL>) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        fatalError()
    }
}
