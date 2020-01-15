//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    private let render = NefRender()
    
    public init() {}
    
    public func renderPage(content: String, permalink: String) -> EnvIO<RenderEnvironment, RenderError, (rendered: String, ast: String)> {
        render.renderPage(content: content, generator: generator(permalink: permalink)).map { rendered in
            (rendered: rendered.output, ast: rendered.ast)
        }^
    }
    
    public func renderPage(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<RenderEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        return render.renderPage(content: content, atFile: file, generator: generator(permalink: permalink))
    }
    
    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, filename: filename, generator: generator).map { rendered in
            rendered.pages.all().map { page in page.url }
        }^
    }
    
    public func renderPlaygrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<RenderEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let rendered = EnvIO<RenderEnvironment, RenderError, RendererPlaygrounds>.var()
        let docs = output.appendingPathComponent("docs")
        
        return binding(
            rendered <- self.render.renderPlaygrounds(at: folder, into: docs, filename: self.filename, generator: self.generator),
                     |<-self.buildMainPage(step: step.increment(2), mainPage: mainPage, docs: docs),
                     |<-self.buildSideBar(step: step.increment(3), rendered: rendered.get, output: output),
        yield: rendered.get.playgrounds.all().map { info in info.playground.url })^
    }
    
    // MARK: - generator <helpers>
    private func generator(playgroundTitle: String, pageTitle: String) -> CoreRender {
        generator(permalink: permalink(escapedPlayground: playgroundTitle, escapedPage: pageTitle))
    }
    
    private func generator(permalink: String) -> CoreRender {
        JekyllGenerator(permalink: permalink)
    }
    
    private func filename(page: String) -> String {
        "\(page)/README.md"
    }
    
    private func permalink(escapedPlayground: String, escapedPage: String) -> String {
        "/docs/\(escapedPlayground)/\(escapedPage)/"
    }
    
    // MARK: - private <helpers>
    private func buildMainPage(step: Step, mainPage: URL, docs: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        let file = docs.appendingPathComponent("README.md")
        let content = (try? String(contentsOf: mainPage)) ?? """
                                                             ---
                                                             layout: docs
                                                             permalink: /docs/
                                                             ---
                                                             """
        
        return EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Building main page"),
                |<-env.fileSystem.write(content: content, toFile: file).mapLeft { _ in .render(page: mainPage) },
            yield: ())^.reportStatus(step: step, in: env.console)
        }
    }
    
    private func buildSideBar(step: Step, rendered: RendererPlaygrounds, output: URL) -> EnvIO<RenderEnvironment, RenderError, Void> {
        func sidebarPage(_ page: RendererURL, playground: RendererURL) -> String {
            """
                    - title: \(page)
                      url: \(permalink(escapedPlayground: playground.escapedTitle, escapedPage: page.escapedTitle))
            """
        }
        
        func sidebarPlayground(_ info: RendererPlayground) -> String {
            """
              - title: \(info.playground)
            
                nested_options:
            
            \(info.pages.all().map { page in sidebarPage(page, playground: info.playground) }.joined(separator: "\n\n"))
            """
        }
        
        let data = output.appendingPathComponent("_data")
        let sidebar = data.appendingPathComponent("sidebar.yml")
        let content =   """
                        options:
                        
                        \(rendered.playgrounds.all().map(sidebarPlayground).joined(separator: "\n\n"))
                        """
        
        return EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Building sidebar"),
                |<-env.fileSystem.createDirectory(at: data),
                |<-env.fileSystem.write(content: content, toFile: sidebar),
            yield: ())^.mapLeft { _ in .render(page: sidebar) }.reportStatus(step: step, in: env.console)
        }
    }
}
