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
    typealias RenderingOutput = NefCommon.RenderingOutput<String>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<String>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<String>
    
    public init() {}
    
    public func page(content: String, permalink: String) -> EnvIO<Environment, RenderError, (ast: String, rendered: String)> {
        renderPage(content: content, permalink: permalink).map { rendered in
            (ast: rendered.ast, rendered: self.contentFrom(page: rendered))
        }^
    }
    
    public func page(content: String, permalink: String, filename: String, into output: URL) -> EnvIO<Environment, RenderError, (url: URL, ast: String, rendered: String)> {
        let file = output.appendingPathComponent(filename)
        let rendered = EnvIO<Environment, RenderError, RenderingOutput>.var()
        
        return binding(
            rendered <- self.renderPage(content: content, permalink: permalink),
                     |<-self.writePage(rendered.get, into: file),
        yield: (url: file, ast: rendered.get.ast, rendered: self.contentFrom(page: rendered.get)))^
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
            rendered <- self.renderPlayground(playground),
             written <- self.writePages(rendered.get, into: output),
        yield: written.get)^
    }
    
    public func playgrounds(at folder: URL, mainPage: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        let docs = output.appendingPathComponent(Environment.docs)
        let data = output.appendingPathComponent(Environment.data)
        
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        let written = EnvIO<Environment, RenderError, NEA<URL>>.var()
        
        return binding(
             rendered <- self.renderPlaygrounds(atFolder: folder),
              written <- self.writePlaygrounds(rendered.get, into: docs),
                      |<-self.buildMainPage(mainPage, docs: docs),
                      |<-self.buildSideBar(rendered: rendered.get, data: data),
        yield: written.get)^
    }
    
    // MARK: private <helper>
    private func writePages(_ pages: PlaygroundOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        pages.traverse { info in self.writePage(page: info.page, content: info.output, output: output)^ }^
    }
    
    private func writePage(page: RenderingURL, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        writePage(pathComponent: page.escapedTitle, content: content, output: output)
    }
    
    private func writePage(pathComponent: String, content: RenderingOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        EnvIO { env in
            let file = output.appendingPathComponent(pathComponent).appendingPathComponent("README.md")
            return env.persistence.writePage(content, file).provide(env.fileSystem)
                                  .map { _ in file }^.mapError { _ in .page(file) }
        }^
    }
    
    private func writePlaygrounds(_ playgrounds: PlaygroundsOutput, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        playgrounds.traverse { info in self.writePlayground(playground: info.playground, content: info.output, output: output)^ }^
    }
    
    private func writePlayground(playground: RenderingURL, content: PlaygroundOutput, output: URL) -> EnvIO<Environment, RenderError, URL> {
        content.traverse { info -> EnvIO<Environment, RenderError, URL> in
            let pathComponent = RenderEnvironmentInfo.info(playground: playground, page: info.page).pathComponent
            return self.writePage(pathComponent: pathComponent.isEmpty ? pathComponent : info.page.escapedTitle,
                                  content: info.output,
                                  output: output)
        }.map { _ in playground.url }^
    }
    
    private func writePage(_ page: RenderingOutput, into file: URL) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { env in
            env.persistence.writePage(page, file).provide(env.fileSystem).mapError { _ in .page(file) }
        }
    }
    
    // MARK: private <renders>
    private func renderPage(content: String, permalink: String) -> EnvIO<Environment, RenderError, RenderingOutput> {
        EnvIO { env in env.render.page(content: content).provide(env.jekyllEnvironment(permalink)) }
    }
    
    private func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        EnvIO { env in env.render.playground(playground).provide(env.renderEnvironment) }
    }
    
    private func renderPlaygrounds(atFolder folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        EnvIO { env in env.render.playgrounds(at: folder).provide(env.renderEnvironment) }
    }
    
    // MARK: private <steps>
    private func buildMainPage(_ mainPage: URL, docs: URL) -> EnvIO<Environment, RenderError, Void> {
        let file = docs.appendingPathComponent("README.md")
        let content = try? String(contentsOf: mainPage)
        let defaultContent = """
                             ---
                             layout: docs
                             permalink: /docs/
                             ---
                             """
        let step = JekyllEvent.buildingMainPage(mainPage.path)
        
        return EnvIO { env in
            binding(
                |<-env.progressReport.inProgress(step),
                |<-env.fileSystem.createDirectory(atPath: docs.path),
                |<-env.fileSystem.write(content: content ?? defaultContent, toFile: file.path),
            yield: ())^.mapError { _ in .page(mainPage) }^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func buildSideBar(rendered: PlaygroundsOutput, data: URL) -> EnvIO<Environment, RenderError, Void> {
        func sidebarPage(playground: RenderingURL, page: RenderingURL) -> IO<RenderError, String> {
            Environment.permalink(info: .info(playground: playground, page: page))
                       .mapError { _ in .page(page.url) }^
                       .map { permalink in
                            """
                                     - title: \(page)
                                       url: \(permalink)
                            """
                       }^
        }

        func sidebarPlayground(playground: RenderingURL, info: PlaygroundOutput) -> IO<RenderError, String> {
            info.traverse { (page, _, _) in sidebarPage(playground: playground, page: page) }.map { sidebarPages in
                """
                   - title: \(playground)
                     nested_options:
                \(sidebarPages.all().joined(separator: "\n\n"))
                """
            }^
        }

        func sidebar(_ info: PlaygroundsOutput) -> IO<RenderError, String> {
            info.traverse(sidebarPlayground).map { sidebarPlaygrounds in
                """
                options:

                \(sidebarPlaygrounds.all().joined(separator: "\n\n"))
                
                """
            }^
        }

        let sidebarFile = data.appendingPathComponent("sidebar.yml")
        let content = IO<RenderError, String>.var()
        let step = JekyllEvent.buildingSidebar(sidebarFile.path)
        
        return EnvIO { env in
            binding(
                      |<-env.progressReport.inProgress(step),
                      |<-env.fileSystem.createDirectory(atPath: data.path).mapError { _ in .page(sidebarFile) },
              content <- sidebar(rendered),
                      |<-env.fileSystem.write(content: content.get, toFile: sidebarFile.path).mapError { _ in .page(sidebarFile) },
            yield: ())^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    // MARK: private <utils>
    private func contentFrom(page: RenderingOutput) -> String {
        page.output.all().joined()
    }
}
