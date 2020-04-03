//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCore
import NefModels

import Bow
import BowEffects

public struct Render<A> {
    public typealias Environment = RenderEnvironment<A>
    
    public init() {}
    
    public func page(content: String) -> EnvIO<Environment, RenderError, RenderingOutput<A>> {
        renderPage(content: content, info: .empty)
    }
    
    public func playground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        renderPlayground(RenderingURL(url: playground, title: playgroundName(playground)))
    }
    
    public func playgrounds(at folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput<A>> {
        func merge(playgrounds: NEA<RenderingURL>, output: NEA<PlaygroundOutput<A>>) -> EnvIO<Environment, RenderError, PlaygroundsOutput<A>> {
            guard playgrounds.count == output.count, !playgrounds.all().isEmpty else { return EnvIO.raiseError(.playgrounds)^ }
            
            let tuples = zip(playgrounds.all(), output.all()).map { playground, output in (playground: playground, output: output) }
            return EnvIO.pure(NEA.fromArrayUnsafe(tuples))^
        }
        
        let playgrounds = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, NEA<PlaygroundOutput<A>>>.var()
        let output = EnvIO<Environment, RenderError, PlaygroundsOutput<A>>.var()

        return binding(
            playgrounds <- self.getPlaygrounds(at: folder),
               rendered <- playgrounds.get.traverse(self.renderPlayground),
                 output <- merge(playgrounds: playgrounds.get, output: rendered.get),
        yield: output.get)^
    }
    
    // MARK: - render <helpers>
    private func renderPlayground(_ playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        let pages = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput<A>>.var()
        
        return binding(
                pages <- self.getPages(playground: playground),
             rendered <- self.renderPages(pages.get, inPlayground: playground),
        yield: rendered.get)^
    }
    
    private func renderPages(_ pages: NEA<RenderingURL>, inPlayground playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        func readPlatform(playground: RenderingURL) -> EnvIO<Environment, RenderError, Platform> {
            let info = playground.url.appendingPathComponent("contents.xcplayground")
            guard let xcplayground = try? String(contentsOf: info),
                  let rawPlatform = xcplayground.matches(pattern: "(?<=target-platform=').*(?=>)").first,
                  let extractedPlatform = rawPlatform.components(separatedBy: "'").first?.lowercased(),
                  let platform = Platform(rawValue: extractedPlatform) else {
                    return EnvIO.raiseError(.extractPlatform(info))^
            }
            return EnvIO.pure(platform)^
        }
        
        func readPlayground(page: RenderingURL) -> EnvIO<Environment, RenderError, String> {
            let url = page.url.appendingPathComponent("Contents.swift")
            guard let content = try? String(contentsOf: url) else { return EnvIO.raiseError(.page(url))^ }
            return EnvIO.pure(content)^
        }
        
        func renderPages(_ pages: NEA<RenderingURL>, platform: Platform, inPlayground playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
            pages.traverse { (page: RenderingURL) in
                let content = EnvIO<Environment, RenderError, String>.var()
                let rendered = EnvIO<Environment, RenderError, RenderingOutput<A>>.var()
            
                return binding(
                     content <- readPlayground(page: page),
                    rendered <- self.renderPage(content: content.get, info: .info(playground: playground, page: page)),
                yield: (page: page, platform: platform, output: rendered.get))^
            }^
        }
        
        let platform = EnvIO<Environment, RenderError, Platform>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput<A>>.var()
        
        return binding(
            platform <- readPlatform(playground: playground),
            rendered <- renderPages(pages, platform: platform.get, inPlayground: playground),
        yield: rendered.get)^
    }
    
    private func renderPage(content: String, info: RenderEnvironmentInfo) -> EnvIO<Environment, RenderError, RenderingOutput<A>> {
        EnvIO { env in
            let rendered = IO<RenderError, RenderingOutput<A>>.var()
            let step = RenderEvent.processingPage(info.data?.page.title ?? "content")
            
            return binding(
                         |<-env.progressReport.inProgress(step),
                rendered <- env.nodePrinter(content).provide(info)
                               .mapError { e in .content(info: e) },
                yield: rendered.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    // MARK: - private <helpers>
    private func getPages(playground: RenderingURL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let pages = IO<RenderError, NEA<URL>>.var()
            let rendererPages = IO<RenderError, NEA<RenderingURL>>.var()
            let step = RenderEvent.gettingPagesFromPlayground(playground.description)
            
            return binding(
                |<-env.progressReport.inProgress(step),
                pages <- env.xcodePlaygroundSystem.pages(in: playground.url)
                    .provide(env.fileSystem)
                    .mapError { _ in .getPages(playground: playground.url) },
                rendererPages <- pages.get.traverse { url in RenderingURL(url: url, title: self.pageName(url)).io() },
                yield: rendererPages.get)^
                .step(step, reportCompleted: env.progressReport)
        }
    }
    
    private func getPlaygrounds(at folder: URL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let playgrounds = IO<RenderError, NEA<URL>>.var()
            let rendered = IO<RenderError, NEA<RenderingURL>>.var()
            let step = RenderEvent.gettingPlaygrounds(folder.lastPathComponent.removeExtension)
            
            return binding(
                |<-env.progressReport.inProgress(step),
                playgrounds <- env.xcodePlaygroundSystem.linkedPlaygrounds(at: folder)
                    .provide(env.fileSystem)
                    .mapError { _ in .getPlaygrounds(folder: folder) },
                rendered <- playgrounds.get.traverse { url in RenderingURL(url: url, title: self.playgroundName(url)).io() },
                yield: rendered.get)^
                .step(step, reportCompleted: env.progressReport)
        }
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
}
