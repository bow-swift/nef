//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import NefModels
import NefCore
import Bow

/// Carbon view definition
protocol CarbonView: NSView {
    func load(carbon: CarbonModel, callback: @escaping (Either<CarbonError, Image>) -> Void)
}

/// Web view where loading/downloading the carbon configuration
class CarbonWKWebView: WKWebView, WKNavigationDelegate, CarbonView {
    private var carbon: CarbonModel?
    private var callback: ((Either<CarbonError, Image>) -> Void)?
    private var isCached: Bool = false
    
    init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(carbon: CarbonModel, callback: @escaping (Either<CarbonError, Image>) -> Void) {
        self.carbon = carbon
        self.callback = callback
        isCached ? launchCachedRequest() : buildCache()
    }
    
    // MARK: private methods
    private func buildCache() {
        let style  = CarbonStyle(background: .bow, theme: .dracula, size: .x5, fontType: .firaCode, lineNumbers: true, watermark: true)
        let carbon = CarbonModel(code: "", style: style)
        let request = CarbonViewer.urlRequest(from: carbon)
        launch(carbonRequest: request)
    }
    
    private func launchCachedRequest() {
        guard let carbon = carbon else { didFailLoadingCarbonWebView(); return }
        let request = CarbonViewer.urlRequest(from: carbon)
        
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
            self.launch(carbonRequest: request)
        }
    }
    
    private func launch(carbonRequest: URLRequest) {
        self.load(carbonRequest)
    }
    
    private func screenshot() {
        guard let carbon = carbon else { didFailLoadingCarbonWebView(); return }
        
        let screenshotError = CarbonError(snippet: carbon.code, cause: .invalidSnapshot)
        let scale = CGFloat(carbon.style.size.rawValue)
        
        setZoom(in: self, scale: scale)
        carbonRectArea(in: self, zoom: scale) { configuration in
            guard let configuration = configuration else {
                self.callback?(.left(screenshotError)); return
            }
            
            self.takeSnapshot(with: configuration) { (image, error) in
                guard let image = image?.image(usingType: .png, metadata: carbon.code) else {
                    self.callback?(.left(screenshotError)); return
                }
                
                self.callback?(.right(image))
            }
        }
    }
    
    private func setZoom(in webView: WKWebView, scale: CGFloat) {
        webView.setMagnification(scale, centeredAt: CGPoint(x: 0, y: 0))
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectWatermark()
        isCached ? screenshot() : launchCachedRequest()
        isCached = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        didFailLoadingCarbonWebView()
    }
    
    private func didFailLoadingCarbonWebView() {
        let error = CarbonError(snippet: carbon?.code ?? "", cause: .notFound)
        callback?(.left(error))
    }
    
    // MARK: javascript <helpers>
    private func carbonRectArea(in webView: WKWebView, zoom: CGFloat, completion: @escaping (WKSnapshotConfiguration?) -> Void) {
        let container = "document.getElementsByClassName('export-container')[0]"
        let getWidth  = "\(container).scrollWidth"
        let getHeight = "\(container).scrollHeight"
        
        webView.evaluateJavaScript(resetPosition + resetBackgroundColor + "[\(getWidth), \(getHeight)]") { (result, _) in
            guard let inset = result as? [CGFloat], inset.count == 2 else {
                completion(nil); return
            }
            
            let (w, h) = (inset[0], inset[1])
            let padding: CGFloat = 10
            let padding_x2 = 2 * padding
            let rect = CGRect(x: padding, y: padding, width: w * zoom - padding_x2, height: h * zoom - padding_x2)
            let configuration = WKSnapshotConfiguration()
            configuration.rect = rect
            
            completion(configuration)
        }
    }
    
    private func injectWatermark() {
        let showWatermark = carbon?.style.watermark ?? false
        guard showWatermark else { return }
        evaluateJavaScript(injectPoweredByJS + injectNefLogoJS)
    }
}

// MARK: nef watermark
private extension CarbonWKWebView {
    private var resetPosition: String {
        return "var main = document.getElementsByClassName('main')[0];" +
               "var container = document.getElementsByClassName('export-container')[0];" +
               "main.replaceWith(container);" +
               "container.className = 'export-container';" +
               "container.setAttribute('style', 'position: absolute; float: left; top: 0px');"
    }
    
    private var resetBackgroundColor: String {
        return "var html = document.getElementsByTagName('html')[0];" +
               "var body = document.getElementsByTagName('body')[0];" +
               "var layersToEliminate = document.getElementsByClassName('eliminateOnRender');" +
               "html.setAttribute('style', 'background-color: white');" +
               "body.setAttribute('style', 'background-color: white');" +
               "while (layersToEliminate.length > 0) { layersToEliminate[0].parentNode.removeChild(layersToEliminate[0]); };"
    }
    
    private var injectPoweredByJS: String {
        return "var terminalTitle = document.getElementsByClassName('window-title-container')[0];" +
               "terminalTitle.firstElementChild.hidden = true;" +
               "var titleNode = document.createElement('span');" +
               "titleNode.innerHTML = 'Powered by <span style=\"color:#b2b2b2;\">nef</span>';" +
               "titleNode.setAttribute('style', 'color:#999999; font-size:13px; font-family:\"Space Mono\"; font-weight: 50');" +
               "terminalTitle.appendChild(titleNode);"
    }
    
    private var injectNefLogoJS: String {
        return "var controlContainer = document.getElementsByClassName('window-controls')[0];" +
               "var logoNode = document.createElement('img');" +
               "logoNode.setAttribute('src', 'data:image/svg+xml;base64,\(Assets.Base64.favicon)');" +
               "logoNode.setAttribute('height', '25');" +
               "logoNode.setAttribute('style', 'position: absolute; top: -4px; right: 6px');" +
               "controlContainer.appendChild(logoNode);"
    }
}
