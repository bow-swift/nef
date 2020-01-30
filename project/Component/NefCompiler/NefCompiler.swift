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
    
    public func page(content: String) -> EnvIO<Environment, RenderError, Void> {
        let code = EnvIO<Environment, RenderError, RenderingOutput>.var()
        
        return binding(
            code <- self.renderPage(content: content),
                 |<-self.compile(page: code.get),
        yield: ())^
    }
    
    public func playground(_ playground: URL) -> EnvIO<Environment, RenderError, Void> {
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput>.var()
        
        return binding(
             rendered <- self.renderPlayground(playground),
                      |<-self.compile(pages: rendered.get),
        yield: ())^
    }
    
    public func playgrounds(atFolder folder: URL, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        let xcworkspace = EnvIO<Environment, RenderError, URL>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundsOutput>.var()
        
        return binding(
               rendered <- self.renderPlaygrounds(atFolder: folder),
            xcworkspace <- self.xcworkspace(atFolder: folder),
                        |<-self.compile(workspace: xcworkspace.get, platform: self.platform(in: rendered.get), cached: cached),
//                        |<-self.compile(playgrounds: rendered.get),
        yield: ())^
    }
    
    // MARK: private <renders>
    private func renderPage(content: String) -> EnvIO<Environment, RenderError, RenderingOutput> {
        EnvIO { env in
            env.render.page(content: content).provide(env.codeEnvironment)
        }
    }
    
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
    
    // MARK: private <compiler>
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
    
    private func compile(page: RenderingOutput) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { (env: Environment) in
            env.compilerSystem.compile(page: page).provide(env.compilerEnvironment).mapError { _ in .content }
        }
    }
    
    private func compile(pages: PlaygroundOutput) -> EnvIO<Environment, RenderError, Void> {
        pages.traverse { info in self.compile(page: info.output) }.map { _ in () }^
    }
    
    private func compile(playgrounds: PlaygroundsOutput) -> EnvIO<Environment, RenderError, Void> {
        playgrounds.traverse { playground in
            self.compile(pages: playground.output)
        }.map { _ in () }^
    }
    
    private func compile(workspace: URL, platform: Platform, cached: Bool) -> EnvIO<Environment, RenderError, Void> {
        EnvIO { env in
            env.compilerSystem.compile(xcworkspace: workspace, platform: platform, cached: cached).provide(env.compilerEnvironment).mapError { _ in .workspace(workspace) }
        }
    }
    
    // MARK: private <utils>
    func platform(in playgrounds: PlaygroundsOutput) -> Platform {
        playgrounds.head.output.head.platform
    }
}
