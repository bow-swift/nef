//  Copyright © 2020 The nef Authors.

import AppKit
import NefCore
import NefModels
import NefRender
import NefCarbon

import Bow
import BowEffects

public extension CarbonAPI {
    
    static func render(content: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, NEA<Data>> {
        renderVerbose(content: content, style: style).map { info in info.images }^
    }
    
    static func renderVerbose(content: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, (ast: String, images: NEA<Data>)> {
        NefCarbon.Carbon()
                 .page(content: content)
                 .contramap { console in environment(console: console, style: style) }
                 .mapError { _ in nef.Error.carbon() }
    }
    
    static func render(code: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, Data> {
        renderVerbose(code: code, style: style).map { info in info.image }^
    }
    
    static func renderVerbose(code: String, style: CarbonStyle) -> EnvIO<Console, nef.Error, (ast: String, image: Data)> {
        renderVerbose(content: code, style: style).map { output in (ast: output.ast, image: output.images.head) }^
    }
    
    static func render(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<Console, nef.Error, URL> {
        renderVerbose(content: content, style: style, filename: filename, into: output).map { output in output.url }^
    }
    
    static func renderVerbose(content: String, style: CarbonStyle, filename: String, into output: URL) -> EnvIO<Console, nef.Error, (ast: String, url: URL)> {
        NefCarbon.Carbon()
                 .page(content: content, filename: filename.removeExtension, into: output)
                 .contramap { console in environment(console: console, style: style) }
                 .mapError { e in nef.Error.carbon(info: "\(e)") }
    }
    
    static func render(playground: URL, style: CarbonStyle, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefCarbon.Carbon()
                 .playground(playground, into: output)
                 .contramap { console in environment(console: console, style: style) }
                 .mapError { _ in nef.Error.carbon() }
    }
    
    static func render(playgroundsAt: URL, style: CarbonStyle, into output: URL) -> EnvIO<Console, nef.Error, NEA<URL>> {
        NefCarbon.Carbon()
                 .playgrounds(at: playgroundsAt, into: output)
                 .contramap { console in environment(console: console, style: style) }
                 .mapError { _ in nef.Error.carbon() }
    }
    
    static func request(configuration: CarbonModel) -> URLRequest {
        NefCarbon.Carbon()
                 .request(configuration: configuration)
    }
    
    static func view(configuration: CarbonModel) -> NefModels.CarbonView {
        NefCarbon.Carbon()
                 .view(configuration: configuration)
    }
    
    // MARK: - private <helpers>
    private static func environment(console: Console, style: CarbonStyle) -> NefCarbon.Carbon.Environment {
        .init(console: console,
              fileSystem: MacFileSystem(),
              persistence: .init(),
              playgroundSystem: MacPlaygroundSystem(),
              style: style,
              carbonPrinter: CoreRender.carbon.render)
    }
}
