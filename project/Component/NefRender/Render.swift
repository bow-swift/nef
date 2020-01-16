//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import NefCore

import Bow
import BowEffects

public struct Render {
    
    public init() {}
    
    public func renderPage(content: String) -> EnvIO<RenderEnvironment, RenderError, RendererOutput> {
        let env = EnvIO<RenderEnvironment, RenderError, RenderEnvironment>.var()
        let rendered = EnvIO<RenderEnvironment, RenderError, RendererOutput>.var()
        
        return binding(
                 env <- ask(),
            rendered <- self.renderPage(content: content, nodePrinter: env.get.nodePrinter(RendererPage.empty)),
        yield: rendered.get)^
    }
    
    public func renderPage(content: String, atFile file: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let env = EnvIO<RenderEnvironment, RenderError, RenderEnvironment>.var()
        let rendered = EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)>.var()
        
        return binding(
                 env <- ask(),
            rendered <- self.renderPage(content: content, atFile: file, nodePrinter: env.get.nodePrinter(RendererPage.empty)),
        yield: rendered.get)^
    }
    
    public func renderPlayground(_ playground: URL, into output: URL, filename: @escaping (_ page: RendererPage) -> String) -> EnvIO<RenderEnvironment, RenderError, RendererPlayground> {
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        let playgroundName = self.playgroundName(playground)
        let escapedPlaygroundTitle = escaped(filename: playgroundName)
        let output = output.appendingPathComponent(escapedPlaygroundTitle)

        let pages = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<RendererURL>.self)

        return binding(
              pages <- self.getPages(step: step.increment(1), playground: playground),
           rendered <- self.renderPages(pages: pages.get, inPlayground: playground, output: output, filename: filename),
        yield: RendererPlayground(playground: RendererURL(url: playground, title: playgroundName, escapedTitle: escapedPlaygroundTitle), pages: rendered.get))^
    }
    
    public func renderPlaygrounds(at folder: URL, into output: URL, filename: @escaping (_ page: RendererPage) -> String) -> EnvIO<RenderEnvironment, RenderError, RendererPlaygrounds> {
        let step: Step = .init(total: 2, partial: 0, duration: .seconds(1))
        let playgrounds = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<URL>.self)
        let rendered = EnvIOPartial<RenderEnvironment, RenderError>.var(NEA<RendererPlayground>.self)
        
        return binding(
            playgrounds <- self.getPlaygrounds(step: step.increment(1), at: folder),
               rendered <- playgrounds.get.traverse { playground in self.renderPlayground(playground, into: output, filename: filename) }^,
        yield: RendererPlaygrounds(playgrounds: rendered.get))^
    }
    
    // MARK: - render <helpers>
    private func renderPages(pages: NEA<URL>, inPlayground: URL, output: URL, filename: @escaping (_ page: RendererPage) -> String) -> EnvIO<RenderEnvironment, RenderError, NEA<RendererURL>> {
        pages.traverse { (page: URL) in
            let playgroundName = self.playgroundName(inPlayground)
            let pageName = self.playgroundPageName(page)
            let escapedPlaygroundTitle = self.escaped(filename: playgroundName)
            let escapedPageTitle = self.escaped(filename: pageName)
            
            let rendererPageURL = RendererURL(url: page, title: pageName, escapedTitle: escapedPageTitle)
            let rendererPlaygroundURL = RendererURL(url: inPlayground, title: playgroundName, escapedTitle: escapedPlaygroundTitle)
            let rendererPage = RendererPage(playground: rendererPlaygroundURL, page: rendererPageURL)
            let file = output.appendingPathComponent("\(filename(rendererPage).removeExtension).md")
        
            return self.renderPage(rendererPage, atFile: file)
        }^
    }
    
    private func renderPage(_ info: RendererPage, atFile file: URL) -> EnvIO<RenderEnvironment, RenderError, RendererURL> {
        let page = info.page.url.appendingPathComponent("Contents.swift")
        guard let content = try? String(contentsOf: page) else { return EnvIO.raiseError(.render(page: page))^ }
        
        let env = EnvIO<RenderEnvironment, RenderError, RenderEnvironment>.var()
        let rendered =  EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)>.var()
        
        return binding(
                 env <- ask(),
            rendered <- self.renderPage(content: content, atFile: file, nodePrinter: env.get.nodePrinter(info)),
        yield: RendererURL(url: rendered.get.url, title: info.page.title, escapedTitle: info.page.escapedTitle))^
    }
       
    public func renderPage(content: String, atFile file: URL, nodePrinter: CoreRender) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let rendered = EnvIO<RenderEnvironment, RenderError, RendererOutput>.var()
        
        return binding(
            rendered <- self.renderPage(content: content, nodePrinter: nodePrinter),
                     |<-self.structure(step: step.increment(2), output: file.deletingLastPathComponent()),
                     |<-self.persistContent(step: step.increment(3), content: rendered.get.output, atFile: file),
        yield: (url: file, ast: rendered.get.ast, trace: rendered.get.output))^
    }
    
    private func renderPage(content: String, nodePrinter: CoreRender) -> EnvIO<RenderEnvironment, RenderError, RendererOutput> {
        EnvIO.async { callback in
            if let rendered = nodePrinter.render(content: content) {
                callback(.right(rendered))
            } else {
                callback(.left(.renderContent))
            }
        }^
    }
    
    // MARK: - format file <helpers>
    private func playgroundName(_ playground: URL) -> String {
        playground.lastPathComponent.removeExtension
    }
    
    private func playgroundPageName(_ page: URL) -> String {
        var filename = page.lastPathComponent.removeExtension
        if filename == "README" {
            filename = page.deletingLastPathComponent().lastPathComponent.removeExtension
        }
        
        return filename
    }
    
    private func escaped(filename: String) -> String {
        filename.lowercased().replacingOccurrences(of: "?", with: "-")
                             .replacingOccurrences(of: " ", with: "-")
    }
    
    // MARK: - private <helpers>
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
