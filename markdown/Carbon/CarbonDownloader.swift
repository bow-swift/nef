//  Copyright © 2019 The nef Authors.

import Foundation
import WebKit
import AppKit

struct Carbon {
    let size: CarbonWebView.CarbonSize
    let code: String
}

class CarbonApp {
    let app = NSApplication.shared
    
    func downloadCarbon(_ configuration: Carbon, filename: String, completion: @escaping (Result<String, Error>) -> Void) {
        app.deactivate()
        
        let carbonAppDelegate = CarbonAppDelegate(carbon: configuration, filename: filename, completion: completion)
        app.delegate = carbonAppDelegate
        app.run()
    }
}

// MARK: Carbon downloader
protocol CarbonWebViewDelegate: class {
    func didFailLoadCarbon()
    func didLoadCarbon()
}

class CarbonWebView: WKWebView, WKNavigationDelegate {
    
    enum CarbonSize: String {
        case x1 = "14px"
        case x2 = "18px"
        case x4 = "22px"
    }
    
    
    private let filename: String
    private let carbon: Carbon
    weak var carbonDelegate: CarbonWebViewDelegate?
    
    init(frame: CGRect, carbon: Carbon, filename: String) {
        self.carbon = carbon
        self.filename = filename
        
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCarbon(isEmbeded: Bool = true) {
        let embededParam = isEmbeded ? "/embeded" : ""
        let customization = "bg=rgba(171%2C%20184%2C%20195%2C%201)&t=lucario&wt=none&l=swift&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=35px&ph=35px&ln=true&fm=Hack&lh=133%25&si=false&es=2x&wm=false"
        let size = "fs=\(carbon.size.rawValue)"
        let code = "code=\(carbon.code.requestPathEncoding)"
        let query = "https://carbon.now.sh\(embededParam)/?\(customization)&\(size)&\(code)"
        let truncatedQuery = query[URLRequest.URLLenghtAllowed]
        
        let url = URL(string: truncatedQuery)!
        load(URLRequest(url: url))
    }
    
    private func screenshot() {
        hideCopyButton(in: self)
        carbonRectArea(in: self) { configuration in
            guard let configuration = configuration else {
                self.carbonDelegate?.didFailLoadCarbon(); return
            }
            
            self.takeSnapshot(with: configuration) { (image, error) in
                guard let image = image else { self.carbonDelegate?.didFailLoadCarbon(); return }
                _ = image.writeToFile(file: "\(self.filename).png", atomically: true, usingType: .png)
                self.carbonDelegate?.didLoadCarbon()
            }
        }
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        screenshot()
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


class CarbonAppDelegate: NSObject, NSApplicationDelegate {
    
    private class CarbonScreen: NSScreen {
        static let bounds = NSRect(x: 0, y: 0, width: 3000, height: 5000)
        
        override var frame: NSRect { return CarbonScreen.bounds }
        override var visibleFrame: NSRect { return CarbonScreen.bounds }
    }
    
    let window = NSWindow(contentRect: CarbonScreen.bounds,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: true,
                          screen: CarbonScreen())
    
    private let carbon: Carbon
    private let filename: String
    private let completion: (Result<String, Error>) -> Void
    private var carbonWebView: CarbonWebView?
    
    init(carbon: Carbon, filename: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.carbon = carbon
        self.filename = filename
        self.completion = completion
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        carbonWebView = CarbonWebView(frame: window.contentView!.bounds, carbon: carbon, filename: filename)
        carbonWebView?.carbonDelegate = self
        
        window.contentView?.addSubview(carbonWebView!)
        carbonWebView?.loadCarbon(isEmbeded: true)
    }
}

extension CarbonAppDelegate: CarbonWebViewDelegate {
    
    func didFailLoadCarbon() {
        // TODO
    }
    
    func didLoadCarbon() {
        // TODO
    }
}
