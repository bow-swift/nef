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
        let themeItem = URLQueryItem(name: "t", value: "lucario")
        let windowsThemeItem = URLQueryItem(name: "wt", value: "none")
        let languageItem = URLQueryItem(name: "l", value: "swift")
        let dropShadowItem = URLQueryItem(name: "ds", value: "true")
        let shadowYoffsetItem = URLQueryItem(name: "dsyoff", value: "20px")
        let shadowBlurItem = URLQueryItem(name: "dsblur", value: "68px")
        let windowsControlItem = URLQueryItem(name: "wc", value: "true")
        let autoAdjustWidthItem = URLQueryItem(name: "wa", value: "true")
        let verticalPaddingItem = URLQueryItem(name: "pv", value: "35px")
        let horizontalPaddingItem = URLQueryItem(name: "ph", value: "35px")
        let lineNumbersItem = URLQueryItem(name: "ln", value: "true")
        let fontItem = URLQueryItem(name: "fm", value: "Hack")
        let fontSizeItem = URLQueryItem(name: "fs", value: "\(carbon.style.size.fontSize)")
        let lineHeightItem = URLQueryItem(name: "lh", value: "133%25")
        let exportSizeItem = URLQueryItem(name: "sl", value: "\(carbon.style.size)")
        let carbonWatermarkItem = URLQueryItem(name: "wm", value: "false")
        let codeItem = URLQueryItem(name: "code", value: carbon.code.length(limit: URLRequest.URLLenghtLimit))
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "carbon.now.sh"
        urlComponents.path = isEmbeded ? "/embeded" : ""
        urlComponents.queryItems = [backgroundColorItem, themeItem, windowsThemeItem, languageItem, dropShadowItem, shadowYoffsetItem, shadowBlurItem, windowsControlItem, autoAdjustWidthItem, verticalPaddingItem, horizontalPaddingItem, lineNumbersItem, fontItem, fontSizeItem, lineHeightItem, exportSizeItem, carbonWatermarkItem, codeItem]
        
        let url = urlComponents.url?.absoluteString.urlEncoding ?? ""
        return URLRequest(url: URL(string: url)!)
    }
    
    private func screenshot() {
        guard let filename = filename, let code = carbon?.code else { didFailLoadingCarbonWebView(); return }
        let screenshotError = CarbonError(filename: filename, snippet: code, error: .invalidSnapshot)
        
        hideCopyButton(in: self)
        carbonRectArea(in: self) { configuration in
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
    private func carbonRectArea(in webView: WKWebView, completion: @escaping (WKSnapshotConfiguration?) -> Void) {
        let container = "document.getElementsByClassName('container-bg')[0]"
        let getX = "\(container).offsetParent.offsetLeft"
        let getY = "\(container).offsetParent.offsetTop"
        let getWidth = "\(container).scrollWidth"
        let getHeight = "\(container).scrollHeight"
        
        webView.evaluateJavaScript("[\(getX), \(getY), \(getWidth), \(getHeight)]") { (result, _) in
            guard let inset = result as? [CGFloat], inset.count == 4 else {
                completion(nil); return
            }
            
            let offset: CGFloat = 6
            let (x, y, w, h) = (inset[0]+offset, inset[1]+offset, inset[2]-2*offset, inset[3]-2*offset)
            let rect = CGRect(x: x, y: y, width: w, height: h)
            let configuration = WKSnapshotConfiguration()
            configuration.rect = rect
            
            completion(configuration)
        }
    }
    
    private func hideCopyButton(in webView: WKWebView) {
        let hideCopyButton = "document.getElementsByClassName('copy-button')[0].style.display = 'none'"
        webView.evaluateJavaScript(hideCopyButton) { (_, _) in }
    }
}
