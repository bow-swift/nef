//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import Markup


protocol CarbonView: class {
    func load(carbon: Carbon, filename: String, isEmbeded: Bool)
}

protocol CarbonViewDelegate: class {
    func didFailLoadCarbon(error: CarbonError)
    func didLoadCarbon(filename: String)
}


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
        
        let embededParam = isEmbeded ? "/embeded" : ""
        let customization = "bg=rgba(171%2C%20184%2C%20195%2C%201)&t=lucario&wt=none&l=swift&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=35px&ph=35px&ln=true&fm=Hack&lh=133%25&si=false&es=2x&wm=false"
        let size = "fs=\(carbon.style.size.rawValue)"
        let code = "code=\(carbon.code.requestPathEncoding)"
        let query = "https://carbon.now.sh\(embededParam)/?\(customization)&\(size)&\(code)"
        let truncatedQuery = query[URLRequest.URLLenghtAllowed]
        
        let url = URL(string: truncatedQuery)!
        load(URLRequest(url: url))
    }
    
    // MARK: private methods
    private func screenshot() {
        hideCopyButton(in: self)
        carbonRectArea(in: self) { configuration in
            guard let configuration = configuration else {
                self.carbonDelegate?.didFailLoadCarbon(error: .invalidSnapshot); return
            }
            
            self.takeSnapshot(with: configuration) { (image, error) in
                guard let filename = self.filename, let image = image else { self.carbonDelegate?.didFailLoadCarbon(error: .invalidSnapshot); return }
                _ = image.writeToFile(file: "\(filename).png", atomically: true, usingType: .png)
                self.carbonDelegate?.didLoadCarbon(filename: self.filename!)
            }
        }
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        screenshot()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        carbonDelegate?.didFailLoadCarbon(error: .notFound)
    }
    
    // MARK: javascript <helpers>
    private func carbonRectArea(in webView: WKWebView, completion: @escaping (WKSnapshotConfiguration?) -> Void) {
        let xJS = "document.getElementsByClassName('container-bg')[0].offsetParent.offsetLeft"
        let widthJS = "document.getElementsByClassName('container-bg')[0].scrollWidth"
        let heightJS = "document.getElementsByClassName('container-bg')[0].scrollHeight"
        
        webView.evaluateJavaScript(xJS) { (x, _) in
            webView.evaluateJavaScript(widthJS) { (w, _) in
                webView.evaluateJavaScript(heightJS) { (h, _) in
                    guard let x = x as? CGFloat, let w = w as? CGFloat, let h = h as? CGFloat else {
                        completion(nil); return
                    }
                    let rect = CGRect(x: x, y: 0, width: w, height: h)
                    let configuration = WKSnapshotConfiguration()
                    configuration.rect = rect
                    
                    completion(configuration)
                }
            }
        }
    }
    
    private func hideCopyButton(in webView: WKWebView) {
        let hideCopyButton = "document.getElementsByClassName('copy-button')[0].style.display = 'none'"
        webView.evaluateJavaScript(hideCopyButton) { (_, _) in }
    }
}
