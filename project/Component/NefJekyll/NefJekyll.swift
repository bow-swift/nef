//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    public typealias JekyllEnvironment = RenderJekyllEnvironment<String>
    typealias PageOutput  = RenderingOutput<String>.PageOutput
    typealias PlaygroundOutput  = RenderingOutput<String>.PlaygroundOutput
    typealias PlaygroundsOutput = RenderingOutput<String>.PlaygroundsOutput
    
    public init() {}
    
    public func page(content: String, permalink: String) -> EnvIO<JekyllEnvironment, RenderError, (ast: String, rendered: String)> {
        let env = EnvIO<JekyllEnvironment, RenderError, JekyllEnvironment>.var()
        let rendered = EnvIO<JekyllEnvironment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
                 rendered <- env.get.render.page(content: content).contramap { env in env.jekyllEnvironment(permalink) },
        yield: (rendered: self.contentFrom(page: rendered.get), ast: rendered.get.ast))^
    }
    
    public func page(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<JekyllEnvironment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        
        let env = EnvIO<JekyllEnvironment, RenderError, JekyllEnvironment>.var()
        let content = EnvIO<JekyllEnvironment, RenderError, String>.var()
        let rendered = EnvIO<JekyllEnvironment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
             content <- env.get.fileSystem.readFile(atPath: file.path).mapLeft { _ in .renderPage(file) }.env(),
            rendered <- env.get.render.page(content: content.get).contramap { env in env.jekyllEnvironment(permalink) },
                     |<-env.get.renderSystem.writePage(rendered.get, file).contramap(\JekyllEnvironment.fileSystem).mapError { _ in .renderPage(file) },
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<JekyllEnvironment, RenderError, NEA<URL>> {
        let env = EnvIO<JekyllEnvironment, RenderError, JekyllEnvironment>.var()
        let rendered = EnvIO<JekyllEnvironment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<JekyllEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playground(playground).contramap(\JekyllEnvironment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) },
        yield: written.get)^
    }
    
    public func playgrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<JekyllEnvironment, RenderError, NEA<URL>> {
        let docs = output.appendingPathComponent(JekyllEnvironment.docs)
        
        let env = EnvIO<JekyllEnvironment, RenderError, JekyllEnvironment>.var()
        let rendered = EnvIO<JekyllEnvironment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<JekyllEnvironment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playgrounds(at: folder).contramap(\JekyllEnvironment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPlayground(playground: info.playground, content: info.output, output: output) },
                      |<-self.buildMainPage(mainPage, docs: docs),//.contramap(\RenderJekyllEnvironment.fileSystem),
//                      |<-self.buildSideBar(rendered: rendered.get, output: output, permalink: env.get.permalink).contramap(\RenderJekyllEnvironment.renderEnvironment),
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func contentFrom(page: PageOutput) -> String {
        page.output.all().joined()
    }
    
    private func writtenPage(page: RenderingURL, content: PageOutput, output: URL) -> EnvIO<JekyllEnvironment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(page.escapedTitle).appendingPathComponent("README.md")
            return env.renderSystem.writePage(content, file).provide(env.fileSystem)
                                   .map { _ in file }^.mapLeft { _ in .renderPage(file) }
        }^
    }
    
    private func writtenPlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<JekyllEnvironment, RenderError, URL> {
        content.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    // MARK: private <steps>
    private func buildMainPage(_ mainPage: URL, docs: URL) -> EnvIO<JekyllEnvironment, RenderError, Void> {
        let file = docs.appendingPathComponent("README.md")
        let content = (try? String(contentsOf: mainPage)) ?? """
                                                             ---
                                                             layout: docs
                                                             permalink: /docs/
                                                             ---
                                                             """
        
        return EnvIO { env in
            binding(
                |<-env.console.print(information: "Building main page '\(mainPage.path)'"),
                |<-env.fileSystem.createDirectory(atPath: docs.path),
                |<-env.fileSystem.write(content: content, toFile: file.path),
            yield: ())^.mapLeft { _ in .renderPage(mainPage) }^.reportStatus(console: env.console)
        }
    }
    
//        private func buildSideBar(rendered: RendererPlaygrounds, output: URL, permalink: @escaping (RendererPage) -> String) -> EnvIO<RenderEnvironment, RenderError, Void> {
//            func sidebarPage(_ info: RendererPage, permalink: String) -> String {
//                """
//                        - title: \(info.page)
//                          url: \(permalink)
//                """
//            }
//
//            func sidebarPlayground(_ info: RendererPlayground, permalink: (RendererPage) -> String) -> String {
//                """
//                  - title: \(info.playground)
//
//                    nested_options:
//
//                \(info.pages.all().map { page in RendererPage(playground: info.playground, page: page) }
//                                  .map { page in sidebarPage(page, permalink: permalink(page)) }
//                                  .joined(separator: "\n\n"))
//                """
//            }
//
//            func sidebar(permalink: (RendererPage) -> String) -> String {
//                """
//                options:
//
//                \(rendered.playgrounds.all().map { sidebarPlayground($0, permalink: permalink) }
//                                            .joined(separator: "\n\n"))
//                """
//            }
//
//            let data = output.appendingPathComponent("_data")
//            let sidebarFile = data.appendingPathComponent("sidebar.yml")
//
//            return EnvIO { env in
//                binding(
//                    |<-env.fileSystem.createDirectory(at: data),
//                    |<-env.fileSystem.write(content: sidebar(permalink: permalink), toFile: sidebarFile),
//                yield: ())^.mapLeft { _ in .render(page: sidebarFile) }.reportStatus(step: step, in: env.console)
//            }
//        }
    
}
