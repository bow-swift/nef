//  Copyright © 2020 The nef Authors.

import Foundation
import NefUtils
import NefCore
import NefModels

import Bow
import BowEffects

public struct Render<A> {
    public typealias Environment = RenderEnvironment<A>
    public typealias PageOutput  = RendererOutput<A>
    public typealias PlaygroundOutput  = NEA<(page: RendererURL, output: PageOutput)>
    public typealias PlaygroundsOutput = NEA<(playground: RendererURL, output: PlaygroundOutput)>
    
    public init() {}
    
    public func renderPage(content: String) -> EnvIO<Environment, RenderError, PageOutput> {
        let env = EnvIO<Environment, RenderError, Environment>.var()
        let rendered = EnvIO<Environment, RenderError, PageOutput>.var()
        
        return binding(
                 env <- ask(),
            rendered <- env.get.nodePrinter(content).mapLeft { _ in RenderError.renderContent }.env(),
        yield: rendered.get)^
    }
    
    public func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        let playgroundURL = RendererURL(url: playground,
                                        title: playgroundName(playground),
                                        escapedTitle: escaped(filename: playgroundName(playground)))
        
        return renderPlayground(playgroundURL)
    }
    
    public func renderPlaygrounds(at folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        func playgroundsOutputFrom(playgrounds: NEA<RendererURL>, outputs: NEA<PlaygroundOutput>) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
            guard playgrounds.count == outputs.count, !playgrounds.all().isEmpty else { return EnvIO.raiseError(.renderPlaygrounds)^ }
            
            let tuples = zip(playgrounds.all(), outputs.all()).map { playground, output in (playground: playground, output: output) }
            return EnvIO.pure(NEA.fromArrayUnsafe(tuples))^
        }
        
        let playgrounds = EnvIO<Environment, RenderError, NEA<RendererURL>>.var()
        let rendered = EnvIO<Environment, RenderError, NEA<PlaygroundOutput>>.var()
        let output = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()

        return binding(
            playgrounds <- self.getPlaygrounds(at: folder),
               rendered <- playgrounds.get.traverse(self.renderPlayground),
                 output <- playgroundsOutputFrom(playgrounds: playgrounds.get, outputs: rendered.get),
        yield: output.get)^
    }
    
    // MARK: - render <helpers>
    private func renderPlayground(_ playground: RendererURL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        let pages = EnvIO<Environment, RenderError, NEA<RendererURL>>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        
        return binding(
                pages <- self.getPages(playground: playground),
             rendered <- self.renderPages(pages.get),
        yield: rendered.get)^
    }
    
    private func renderPages(_ pages: NEA<RendererURL>) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        pages.traverse { (page: RendererURL) in
            let url = page.url.appendingPathComponent("Contents.swift")
            guard let content = try? String(contentsOf: url) else { return EnvIO.raiseError(.render(page: url))^ }
            return self.renderPage(content: content).map { output in (page: page, output: output) }^
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
    private func getPages(playground: RendererURL) -> EnvIO<Environment, RenderError, NEA<RendererURL>> {
        EnvIO { env in
            let pages = IO<RenderError, NEA<URL>>.var()
            let rendererPages = IO<RenderError, NEA<RendererURL>>.var()
            
            return binding(
                        pages <- env.playgroundSystem.pages(in: playground.url).mapLeft { _ in .getPages(playground: playground.url) },
                rendererPages <- pages.get.traverse { url in RendererURL(url: url,
                                                                         title: self.pageName(url),
                                                                         escapedTitle: self.escaped(filename: self.pageName(url))).io() },
            yield: rendererPages.get)
        }
    }
    
    private func getPlaygrounds(at folder: URL) -> EnvIO<Environment, RenderError, NEA<RendererURL>> {
        EnvIO { env in
            let playgrounds = IO<RenderError, NEA<URL>>.var()
            let rendered = IO<RenderError, NEA<RendererURL>>.var()
            
            return binding(
               playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
                  rendered <- playgrounds.get.traverse { url in RendererURL(url: url,
                                                                            title: self.playgroundName(url),
                                                                            escapedTitle: self.escaped(filename: self.playgroundName(url))).io() },
            yield: rendered.get)
        }
    }
}
