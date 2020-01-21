//  Copyright © 2019 The nef Authors.

import AppKit
import NefModels
import NefCarbon

import Bow
import BowEffects

public extension CarbonAPI {
    
    static func render(carbon: CarbonModel, toFile output: URL) -> IO<nef.Error, URL> {
        func runAsync(carbon: CarbonModel, outputURL: URL) -> IO<nef.Error, URL> {
            IO.async { callback in
                self.carbon(code: carbon.code,
                            style: carbon.style,
                            outputPath: outputURL.path,
                            success: {
                                let file = URL(fileURLWithPath: "\(outputURL.path).png")
                                let fileExist = FileManager.default.fileExists(atPath: file.path)
                                fileExist ? callback(.right(file)) : callback(.left(.carbon))
                            },
                            failure: { error in
                                callback(.left(.invalidSnapshot))
                            })
            }^
        }
        
        guard !Thread.isMainThread else {
            fatalError("carbonIO(_ carbon:,output:) should be invoked in background thread")
        }
        
        let file = IO<nef.Error, URL>.var()
        return binding(
                    continueOn(.main),
            file <- runAsync(carbon: carbon, outputURL: output),
        yield: file.get)^
    }
    
    static func request(with configuration: CarbonModel) -> URLRequest { CarbonViewer.urlRequest(from: configuration) }
    
    static func view(with configuration: CarbonModel) -> CarbonView { CarbonWebView(code: configuration.code, state: configuration.style) }
}


// MARK: - Helpers
fileprivate extension CarbonAPI {
    
    /// Renders a code selection into multiple Carbon images.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - code: content to generate the snippet.
    ///   - style: style to apply to exported code snippet.
    ///   - outputPath: output where to render the snippets.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    static func carbon(code: String, style: CarbonStyle, outputPath: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("carbon(code:style:outputPath:success:failure:) should be invoked in main thread")
        }
        
        let assembler = CarbonAssembler()
        let window = assembler.resolveWindow()
        let view = window.contentView!
        let retainSuccess = { success(); _ = view }
        let retainFailure = { (output: String) in failure(output); _ = view }
        
        carbon(parentView: view,
               code: code,
               style: style,
               outputPath: outputPath,
               success: retainSuccess, failure: retainFailure)
    }
    
    /// Renders a code selection into multiple Carbon images.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - parentView: canvas view where to render Carbon image.
    ///   - code: content to generate the snippet.
    ///   - style: style to apply to exported code snippet.
    ///   - outputPath: output where to render the snippets.
    ///   - success: callback to notify if everything goes well.
    ///   - failure: callback with information to notify if something goes wrong.
    static func carbon(parentView: NSView,
                code: String,
                style: CarbonStyle,
                outputPath: String,
                success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard Thread.isMainThread else {
            fatalError("carbon(parentView:code:style:outputPath:success:failure:) should be invoked in main thread")
        }
        
        let assembler = CarbonAssembler()
        let carbonView = assembler.resolveCarbonView(frame: parentView.bounds)
        let downloader = assembler.resolveCarbonDownloader(view: carbonView, multiFiles: false)
        
        parentView.addSubview(carbonView)
        
        #warning("It must be completed in NefCarbon module refactor")
        fatalError()
//        DispatchQueue(label: "nef-framework", qos: .userInitiated).async {
//            renderCarbon(downloader: downloader,
//                         code: "\(code)\n",
//                         style: style,
//                         outputPath: outputPath,
//                         success: { _ in success() },
//                         failure: failure)
//        }
    }
}
