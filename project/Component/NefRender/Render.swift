//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCore
import NefModels

import Bow
import BowEffects

public struct Render<A> {
    public typealias Environment = RenderEnvironment<A>
    public typealias PageOutput  = RenderingOutput<A>.PageOutput
    public typealias PlaygroundOutput  = RenderingOutput<A>.PlaygroundOutput
    public typealias PlaygroundsOutput = RenderingOutput<A>.PlaygroundsOutput
    
    public init() {}
    
    public func page(content: String, pageName: String = "") -> EnvIO<Environment, RenderError, PageOutput> {
        EnvIO { env in
            let rendered = IO<RenderError, PageOutput>.var()
            
            return binding(
                         |<-env.console.print(information: "\t• Rendering page \(pageName.isEmpty ? "content" : "'\(pageName)'")"),
                rendered <- env.nodePrinter(content).mapLeft { _ in RenderError.renderContent },
            yield: rendered.get)^.reportStatus(console: env.console)
        }
    }
    
    public func playground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        self.renderPlayground(RenderingURL(url: playground,
                                           title: playgroundName(playground),
                                           escapedTitle: escaped(filename: playgroundName(playground))))
    }
    
    public func playgrounds(at folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        func playgroundsOutputFrom(playgrounds: NEA<RenderingURL>, outputs: NEA<PlaygroundOutput>) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
            guard playgrounds.count == outputs.count, !playgrounds.all().isEmpty else { return EnvIO.raiseError(.renderPlaygrounds)^ }
            
            let tuples = zip(playgrounds.all(), outputs.all()).map { playground, output in (playground: playground, output: output) }
            return EnvIO.pure(NEA.fromArrayUnsafe(tuples))^
        }
        
        let playgrounds = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, NEA<PlaygroundOutput>>.var()
        let output = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()

        return binding(
            playgrounds <- self.getPlaygrounds(at: folder),
               rendered <- playgrounds.get.traverse(self.renderPlayground),
                 output <- playgroundsOutputFrom(playgrounds: playgrounds.get, outputs: rendered.get),
        yield: output.get)^
    }
    
    // MARK: - render <helpers>
    private func renderPlayground(_ playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        let pages = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        
        return binding(
                pages <- self.getPages(playground: playground),
             rendered <- self.renderPages(pages.get),
        yield: rendered.get)^
    }
    
    private func renderPages(_ pages: NEA<RenderingURL>) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        pages.traverse { (page: RenderingURL) in
            let url = page.url.appendingPathComponent("Contents.swift")
            guard let content = try? String(contentsOf: url) else { return EnvIO.raiseError(.renderPage(url))^ }
            let filename = url.path.parentPath.filename.removeExtension
            return self.page(content: content, pageName: filename).map { output in (page: page, output: output) }^
        }^
    }
    
    // MARK: - format file <helpers>
    private func playgroundName(_ playground: URL) -> String {
        playground.lastPathComponent.removeExtension
    }
    
    private func pageName(_ page: URL) -> String {
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
    private func getPages(playground: RenderingURL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let pages = IO<RenderError, NEA<URL>>.var()
            let rendererPages = IO<RenderError, NEA<RenderingURL>>.var()
            
            return binding(
                              |<-env.console.print(information: "Get pages in playground '\(playground)'"),
                        pages <- env.playgroundSystem.pages(in: playground.url).mapLeft { _ in .getPages(playground: playground.url) },
                rendererPages <- pages.get.traverse { url in RenderingURL(url: url,
                                                                          title: self.pageName(url),
                                                                          escapedTitle: self.escaped(filename: self.pageName(url))).io() },
            yield: rendererPages.get)^.reportStatus(console: env.console)
        }
    }
    
    private func getPlaygrounds(at folder: URL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let playgrounds = IO<RenderError, NEA<URL>>.var()
            let rendered = IO<RenderError, NEA<RenderingURL>>.var()
            
            return binding(
                           |<-env.console.print(information: "Get playgrounds in '\(folder.lastPathComponent.removeExtension)'"),
               playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
                  rendered <- playgrounds.get.traverse { url in RenderingURL(url: url,
                                                                             title: self.playgroundName(url),
                                                                             escapedTitle: self.escaped(filename: self.playgroundName(url))).io() },
            yield: rendered.get)^.reportStatus(console: env.console)
        }
    }
}
