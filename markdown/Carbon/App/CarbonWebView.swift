//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import Markup


/// Carbon view definition
protocol CarbonView: class {
    func load(carbon: Carbon, filename: String, isEmbeded: Bool)
}

protocol CarbonViewDelegate: class {
    func didFailLoadCarbon(error: CarbonError)
    func didLoadCarbon(filename: String)
}


/// Web view where loading/downloading the carbon configuration
class CarbonWebView: WKWebView, WKNavigationDelegate, CarbonView {

    private var filename: String?
    private var carbon: Carbon?
    weak var carbonDelegate: CarbonViewDelegate?
    
    init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(carbon: Carbon, filename: String, isEmbeded: Bool) {
        self.filename = filename
        self.carbon = carbon
        load(urlRequest(from: carbon, isEmbeded: isEmbeded))
    }
    
    // MARK: private methods
    private func urlRequest(from carbon: Carbon, isEmbeded: Bool) -> URLRequest {
        let backgroundColorItem = URLQueryItem(name: "bg", value: "\(carbon.style.background)")
        let themeItem = URLQueryItem(name: "t", value: carbon.style.theme.rawValue)
        let windowsThemeItem = URLQueryItem(name: "wt", value: "none")
        let languageItem = URLQueryItem(name: "l", value: "swift")
        let dropShadowItem = URLQueryItem(name: "ds", value: "true")
        let shadowYoffsetItem = URLQueryItem(name: "dsyoff", value: "20px")
        let shadowBlurItem = URLQueryItem(name: "dsblur", value: "68px")
        let windowsControlItem = URLQueryItem(name: "wc", value: "true")
        let autoAdjustWidthItem = URLQueryItem(name: "wa", value: "true")
        let verticalPaddingItem = URLQueryItem(name: "pv", value: "56px")
        let horizontalPaddingItem = URLQueryItem(name: "ph", value: "56px")
        let lineNumbersItem = URLQueryItem(name: "ln", value: carbon.style.lineNumbers ? "true" : "false")
        let fontItem = URLQueryItem(name: "fm", value: carbon.style.fontType.rawValue)
        let fontSizeItem = URLQueryItem(name: "fs", value: "14px")
        let exportSizeCondition = URLQueryItem(name: "si", value: "false")
        let exportSize = URLQueryItem(name: "es", value: "4x")
        let lineHeightItem = URLQueryItem(name: "lh", value: "151%25")
        let carbonWatermarkItem = URLQueryItem(name: "wm", value: "false")
        let codeItem = URLQueryItem(name: "code", value: carbon.code.length(limit: URLRequest.urlLengthAllowed))
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "carbon.now.sh"
        urlComponents.path = isEmbeded ? "/embeded" : ""
        urlComponents.queryItems = [backgroundColorItem, themeItem, windowsThemeItem, languageItem, dropShadowItem, shadowYoffsetItem, shadowBlurItem, windowsControlItem, autoAdjustWidthItem, verticalPaddingItem, horizontalPaddingItem, lineNumbersItem, fontItem, fontSizeItem, lineHeightItem, exportSizeCondition, exportSize, carbonWatermarkItem, codeItem]
        
        let url = urlComponents.url?.absoluteString.urlEncoding ?? "https://github.com/bow-swift/nef"
        return URLRequest(url: URL(string: url)!)
    }
    
    private func screenshot() {
        guard let filename = filename, let code = carbon?.code else { didFailLoadingCarbonWebView(); return }
        let screenshotError = CarbonError(filename: filename, snippet: code, error: .invalidSnapshot)
        let scale: CGFloat = carbon?.style.size.rawValue ?? 1
        
        setZoom(in: self, scale: scale)
        hideCopyButton(in: self)
        carbonRectArea(in: self, zoom: scale) { configuration in
            guard let configuration = configuration else {
                self.carbonDelegate?.didFailLoadCarbon(error: screenshotError)
                return
            }
            
            self.takeSnapshot(with: configuration) { (image, error) in
                guard let image = image else {
                    self.carbonDelegate?.didFailLoadCarbon(error: screenshotError)
                    return
                }
                
                _ = image.writeToFile(file: "\(filename).png", atomically: true, usingType: .png)
                self.carbonDelegate?.didLoadCarbon(filename: filename)
            }
        }
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        screenshot()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        didFailLoadingCarbonWebView()
    }
    
    private func didFailLoadingCarbonWebView() {
        let error = CarbonError(filename: filename ?? "", snippet: carbon?.code ?? "", error: .notFound)
        carbonDelegate?.didFailLoadCarbon(error: error)
    }
    
    // MARK: javascript <helpers>
    private func carbonRectArea(in webView: WKWebView, zoom: CGFloat, completion: @escaping (WKSnapshotConfiguration?) -> Void) {
        let container = "document.getElementsByClassName('container-bg')[0]"
        let getWidth = "\(container).scrollWidth"
        let getHeight = "\(container).scrollHeight"
        
        webView.evaluateJavaScript("[\(getWidth), \(getHeight)]") { (result, _) in
            let offset: CGFloat = 6
            guard let inset = result as? [CGFloat], inset.count == 2 else {
                completion(nil); return
            }
            
            let (w, h) = (inset[0], inset[1])
            let xwindow_2 = webView.visibleRect.width * 0.5
            let width_2 = w * zoom * 0.5
            
            let x: CGFloat = xwindow_2 - width_2
            let y: CGFloat = 0
            let width: CGFloat = w * zoom
            let height: CGFloat = h * zoom
            
            let rect = CGRect(x: x + offset, y: y + offset, width: width - 2*offset, height: height - 2*offset)
            let configuration = WKSnapshotConfiguration()
            configuration.rect = rect
            
            completion(configuration)
        }
    }
    
    private func hideCopyButton(in webView: WKWebView) {
        let hideCopyButton = "document.getElementsByClassName('copy-button')[0].style.display = 'none'"
        webView.evaluateJavaScript(hideCopyButton) { (_, _) in }
    }
    
    private func setZoom(in webView: WKWebView, scale: CGFloat) {
        let w = webView.visibleRect.width
        let w_2 = w * 0.5
        webView.setMagnification(scale, centeredAt: CGPoint(x: -(w_2*scale-w_2)/scale, y: 0))
    }
}
