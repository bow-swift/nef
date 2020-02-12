//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Compiler {
    public typealias Environment = RenderCompilerEnvironment<String>
    typealias RenderingOutput = NefCommon.RenderingOutput<String>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<String>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<String>
    
    public init() {}
    
    public func playground(_ playground: URL, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        let folder = playground.deletingLastPathComponent()
        
        return binding(
             rendered <- self.renderPlayground(playground),
                      |<-self.buildPages(rendered.get, inPlayground: playground, atFolder: folder, cached: cached),
        yield: ())^
    }
    
    public func playgrounds(atFolder folder: URL, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        
        return binding(
            rendered <- self.renderPlaygrounds(atFolder: folder),
                     |<-self.buildPlaygrounds(rendered.get, atFolder: folder, cached: cached),
        yield: ())^
    }
    
    // MARK: private <renders>
    private func renderPlayground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput> {
        EnvIO { env in
            env.render.playground(playground).provide(env.codeEnvironment)
        }
    }
    
    private func renderPlaygrounds(atFolder folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput> {
        EnvIO { env in
            env.render.playgrounds(at: folder).provide(env.codeEnvironment)
        }
    }
    
    // MARK: private <builders>
    private func buildPlaygrounds(_ playgrounds: PlaygroundsOutput, atFolder folder: URL, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        playgrounds.traverse { info in
            self.buildPages(info.output, inPlayground: info.playground.url, atFolder: folder, cached: cached)
        }.void()^
    }
    
    private func buildPages(_ pages: PlaygroundOutput, inPlayground playground: URL, atFolder folder: URL, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        let xcworkspace = EnvIO<Environment, RenderError, URL>.var()
        let frameworks = EnvIO<Environment, RenderError, [URL]>.var()
        
        return binding(
            xcworkspace <- self.xcworkspace(atFolder: folder),
             frameworks <- self.compile(workspace: xcworkspace.get, inProject: folder, platform: pages.head.platform, cached: cached),
                        |<-self.compile(pages: pages, inPlayground: playground, frameworks: frameworks.get),
        yield: ())^
    }
    
    // MARK: private <compiler>
    private func compile(page: RenderingOutput, inPlayground: URL, platform: Platform, frameworks: [URL]) -> EnvIO<Environment, RenderError, Void> {
        let page = page.output.all().joined()
        let env = EnvIO<Environment, RenderError, Environment>.var()
        
        return binding(
            env <- ask(),
                |<-env.get.compilerSystem
                    .compile(page: page, inPlayground: inPlayground, platform: platform, frameworks: frameworks)
                    .contramap(\Environment.compilerEnvironment)
                    .mapError { _ in RenderError.content },
        yield: ())^
    }
    
    private func compile(pages: PlaygroundOutput, inPlayground playground: URL, frameworks: [URL]) -> EnvIO<Environment, RenderError, Void> {
        pages.traverse { info in
            self.compile(page: info.output, inPlayground: playground, platform: info.platform, frameworks: frameworks)
        }.void()^
    }
    
    private func compile(workspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<Environment, RenderError, [URL]> {
        func buildWorkspace(_ workspace: URL, inProject project: URL, platform: Platform, cached: Bool) -> EnvIO<Environment, RenderError, URL> {
            EnvIO { env in
                env.compilerSystem.compile(xcworkspace: workspace, inProject: project, platform: platform, cached: cached)
                                  .provide(env.compilerEnvironment)
                                  .mapError { e in .workspace(workspace, info: "\(e)") }
            }
        }
        
        return EnvIO { env in
            let dependencies = IO<RenderError, URL>.var()
            
            return binding(
                             |<-env.console.print(information: "Building workspace '\(workspace.lastPathComponent.removeExtension)'"),
                dependencies <- buildWorkspace(workspace, inProject: project, platform: platform, cached: cached).provide(env),
            yield: [dependencies.get])^.reportStatus(console: env.console)
        }
    }
    
    // MARK: private <utils>
    private func xcworkspace(atFolder folder: URL) -> EnvIO<Environment, RenderError, URL> {
        func getWorkspaces(atFolder folder: URL) -> EnvIO<Environment, PlaygroundSystemError, NEA<URL>> {
            EnvIO { env in env.playgroundSystem.xcworkspaces(at: folder) }
        }
        
        func assertNumberOf(xcworkspaces: NEA<URL>, equalsTo total: Int) -> EnvIO<Environment, PlaygroundSystemError, Void> {
            xcworkspaces.all().count == total ? EnvIO.pure(())^ : EnvIO.raiseError(.xcworkspaces())^
        }
        
        let xcworkspaces = EnvIO<Environment, PlaygroundSystemError, NEA<URL>>.var()
        
        return binding(
            xcworkspaces <- getWorkspaces(atFolder: folder),
                         |<-assertNumberOf(xcworkspaces: xcworkspaces.get, equalsTo: 1),
        yield: xcworkspaces.get.head)^.mapError { _ in .getWorkspace(folder: folder) }^
    }
    
    func platform(in playgrounds: PlaygroundsOutput) -> Platform {
        playgrounds.head.output.head.platform
    }
}
