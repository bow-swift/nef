//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    private let render = Render()
    
    public init() {}
    
    public func renderPage(content: String, permalink: String) -> EnvIO<RenderJekyllEnvironment, RenderError, (rendered: String, ast: String)> {
        render.renderPage(content: content).contramap { env in env.renderEnvironment(permalink: permalink) }.map { rendered in
            (rendered: rendered.output, ast: rendered.ast)
        }^
    }
    
    public func renderPage(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<RenderJekyllEnvironment, RenderError, (url: URL, ast: String, trace: String)> {
        let file = output.appendingPathComponent(filename)
        return render.renderPage(content: content, atFile: file).contramap { env in env.renderEnvironment(permalink: permalink) }
    }

    public func renderPlayground(_ playground: URL, into output: URL) -> EnvIO<RenderJekyllEnvironment, RenderError, [URL]> {
        render.renderPlayground(playground, into: output, filename: filename).contramap(\RenderJekyllEnvironment.renderEnvironment).map { rendered in
            rendered.pages.all().map { page in page.url }
        }^
    }
    
    public func renderPlaygrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<RenderJekyllEnvironment, RenderError, [URL]> {
        let step: Step = .init(total: 3, partial: 0, duration: .seconds(1))
        let docs = output.appendingPathComponent("docs")
        
        let env = EnvIO<RenderJekyllEnvironment, RenderError, RenderJekyllEnvironment>.var()
        let rendered = EnvIO<RenderJekyllEnvironment, RenderError, RendererPlaygrounds>.var()
        
        return binding(
                 env <- ask(),
            rendered <- self.render.renderPlaygrounds(at: folder, into: docs, filename: self.filename).contramap(\RenderJekyllEnvironment.renderEnvironment),
                     |<-self.buildMainPage(step: step.increment(2), mainPage: mainPage, docs: docs).contramap(\RenderJekyllEnvironment.renderEnvironment),
                     |<-self.buildSideBar(step: step.increment(3), rendered: rendered.get, output: output, permalink: env.get.permalink).contramap(\RenderJekyllEnvironment.renderEnvironment),
        yield: rendered.get.playgrounds.all().map { info in info.playground.url })^
    }
    
    // MARK: - private <helpers>
    private func filename(page info: RendererPage) -> String {
        "\(info.page.escapedTitle)/README.md"
    }
    
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
    
    private func buildSideBar(step: Step, rendered: RendererPlaygrounds, output: URL, permalink: @escaping (RendererPage) -> String) -> EnvIO<RenderEnvironment, RenderError, Void> {
        func sidebarPage(_ info: RendererPage, permalink: String) -> String {
            """
                    - title: \(info.page)
                      url: \(permalink)
            """
        }
        
        func sidebarPlayground(_ info: RendererPlayground, permalink: (RendererPage) -> String) -> String {
            """
              - title: \(info.playground)
            
                nested_options:
            
            \(info.pages.all().map { page in RendererPage(playground: info.playground, page: page) }
                              .map { page in sidebarPage(page, permalink: permalink(page)) }
                              .joined(separator: "\n\n"))
            """
        }
        
        func sidebar(permalink: (RendererPage) -> String) -> String {
            """
            options:
                        
            \(rendered.playgrounds.all().map { sidebarPlayground($0, permalink: permalink) }
                                        .joined(separator: "\n\n"))
            """
        }
        
        let data = output.appendingPathComponent("_data")
        let sidebarFile = data.appendingPathComponent("sidebar.yml")
        
        return EnvIO { env in
            binding(
                |<-env.console.printStep(step: step, information: "Building sidebar"),
                |<-env.fileSystem.createDirectory(at: data),
                |<-env.fileSystem.write(content: sidebar(permalink: permalink), toFile: sidebarFile),
            yield: ())^.mapLeft { _ in .render(page: sidebarFile) }.reportStatus(step: step, in: env.console)
        }
    }
}
