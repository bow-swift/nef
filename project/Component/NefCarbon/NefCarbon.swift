//  Copyright © 2019 The nef Authors.

import AppKit
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Carbon {
    public typealias Environment = RenderCarbonEnvironment<Image>
    typealias RenderingOutput = NefCommon.RenderingOutput<Image>
    typealias PlaygroundOutput  = NefCommon.PlaygroundOutput<Image>
    typealias PlaygroundsOutput = NefCommon.PlaygroundsOutput<Image>
    
    public init() {}
        
    public func page(content: String) -> EnvIO<Environment, RenderError, (ast: String, rendered: NEA<Data>)> {
        fatalError()
    }
    
    public func code(_ code: String) -> EnvIO<Environment, RenderError, (ast: String, rendered: Data)> {
        fatalError()
    }
    
    public func page(content: String, filename: String, into output: URL) -> EnvIO<Environment, RenderError, URL> {
        fatalError()
    }
    
    public func playground(_ playground: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        fatalError()
    }
    
    public func playgrounds(at folder: URL, into output: URL) -> EnvIO<Environment, RenderError, NEA<URL>> {
        fatalError()
    }
    
    public func request(configuration: CarbonModel) -> URLRequest {
        CarbonViewer.urlRequest(from: configuration)
    }
    
    public func view(configuration: CarbonModel) -> NefModels.CarbonView {
        CarbonWebView(code: configuration.code, state: configuration.style)
    }
}
