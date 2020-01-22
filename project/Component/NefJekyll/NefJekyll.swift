//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    public typealias Environment = RenderJekyllEnvironment<String>
    typealias PageOutput  = RenderingOutput<String>.PageOutput
    typealias PlaygroundOutput  = RenderingOutput<String>.PlaygroundOutput
    typealias PlaygroundsOutput = RenderingOutput<String>.PlaygroundsOutput
    
    public init() {}
    
    public func page(content: String, permalink: String) -> EnvIO<Environment, RenderError, (ast: String, rendered: String)> {
        let env = EnvIO<Environment, RenderError, Environment>.var()
        let rendered = EnvIO<Environment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
                 rendered <- env.get.render.page(content: content).contramap { env in env.jekyllEnvironment(permalink) },
        yield: (rendered: self.contentFrom(page: rendered.get), ast: rendered.get.ast))^
    }
    
    public func page(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<Environment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        
        let env = EnvIO<Environment, RenderError, Environment>.var()
        let content = EnvIO<Environment, RenderError, String>.var()
        let rendered = EnvIO<Environment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
             content <- env.get.fileSystem.readFile(atPath: file.path).mapLeft { _ in .renderPage(file) }.env(),
            rendered <- env.get.render.page(content: content.get).contramap { env in env.jekyllEnvironment(permalink) },
                     |<-env.get.renderSystem.writePage(rendered.get, file).contramap(\Environment.fileSystem).mapError { _ in .renderPage(file) },
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let env = EnvIO<Environment, RenderError, Environment>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playground(playground).contramap(\Environment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) },
        yield: written.get)^
    }
    
    public func playgrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let docs = output.appendingPathComponent(Environment.docs)
        let data = output.appendingPathComponent(Environment.data)
        
        let env = EnvIO<Environment, RenderError, Environment>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
                  env <- ask(),
             rendered <- env.get.render.playgrounds(at: folder).contramap(\Environment.renderEnvironment),
              written <- rendered.get.traverse { info in self.writtenPlayground(playground: info.playground, content: info.output, output: docs) },
                      |<-self.buildMainPage(mainPage, docs: docs),
                      |<-self.buildSideBar(rendered: rendered.get, data: data),
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func contentFrom(page: PageOutput) -> String {
        page.output.all().joined()
    }
    
    private func writtenPage(page: RenderingURL, content: PageOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(page.escapedTitle).appendingPathComponent("README.md")
            return env.renderSystem.writePage(content, file).provide(env.fileSystem)
                                   .map { _ in file }^.mapLeft { _ in .renderPage(file) }
        }^
    }
    
    private func writtenPlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        content.traverse { info in self.writtenPage(page: info.page, content: info.output, output: output) }
               .map { _ in playground.url }^
    }
    
    // MARK: private <steps>
    private func buildMainPage(_ mainPage: URL, docs: URL) -> EnvIO<Environment, RenderError, Void> {
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
    
    private func buildSideBar(rendered: PlaygroundsOutput, data: URL) -> EnvIO<Environment, RenderError, Void> {
        func sidebarPage(playground: RenderingURL, page: RenderingURL) -> String {
            """
                - title: \(page)
                  url: \(Environment.permalink(playground: playground, page: page))
            """
        }

        func sidebarPlayground(playground: RenderingURL, info: PlaygroundOutput) -> String {
            """
            - title: \(playground)

              nested_options:

            \(info.all().map { (page, _) in sidebarPage(playground: playground, page: page) }.joined(separator: "\n\n"))
            """
        }

        func sidebar(_ info: PlaygroundsOutput) -> String {
            """
            options:

            \(info.all().map(sidebarPlayground).joined(separator: "\n\n"))
            """
        }

        let sidebarFile = data.appendingPathComponent("sidebar.yml")

        return EnvIO { env in
            binding(
                |<-env.console.print(information: "Building sidebar '\(sidebarFile.path)'"),
                |<-env.fileSystem.createDirectory(atPath: data.path),
                |<-env.fileSystem.write(content: sidebar(rendered), toFile: sidebarFile.path),
            yield: ())^.mapLeft { _ in .renderPage(sidebarFile) }^.reportStatus(console: env.console)
        }
    }
}
