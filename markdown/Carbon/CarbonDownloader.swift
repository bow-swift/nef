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
        carbonRectArea(in: self) { res in
            guard let (configuration, needsScroll) = res else {
                self.carbonDelegate?.didFailLoadCarbon(); return
            }
            
            self.takeSnapshot(with: configuration) { (image, error) in
                _ = image?.writeToFile(file: "\(self.filename).png", atomically: true, usingType: .png)
                self.carbonDelegate?.didLoadCarbon()
            }
        }
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        screenshot()
    }
    
    // MARK: javascript <helpers>
    private func carbonRectArea(in webView: WKWebView, completion: @escaping ((configuration: WKSnapshotConfiguration, needsScroll: Bool)?) -> Void) {
        let xJS = "document.getElementsByClassName('container-bg')[0].offsetParent.offsetLeft"
        let widthJS = "document.getElementsByClassName('container-bg')[0].scrollWidth"
        let heightJS = "document.getElementsByClassName('container-bg')[0].scrollHeight"
        
        webView.evaluateJavaScript(xJS) { (x, _) in
            webView.evaluateJavaScript(widthJS) { (w, _) in
                webView.evaluateJavaScript(heightJS) { (h, _) in
                    guard let x = x as? CGFloat, let w = w as? CGFloat, let h = h as? CGFloat else {
                        completion(nil); return
                    }
                    
                    let rect = CGRect(x: x, y: 0, width: w, height: min(h, webView.visibleRect.height))
                    let needsScroll = h > webView.visibleRect.height
                    let configuration = WKSnapshotConfiguration()
                    configuration.rect = rect
                    
                    completion((configuration: configuration, needsScroll: needsScroll))
                }
            }
        }
    }
    
    private func hideCopyButton(in webView: WKWebView) {
        let hideCopyButton = "document.getElementsByClassName('copy-button')[0].style.display = 'none'"
        webView.evaluateJavaScript(hideCopyButton) { (_, _) in }
    }
}


class CarbonAppDelegate: NSObject, NSApplicationDelegate, CarbonWebViewDelegate {
    
    let window = NSWindow(contentRect: NSMakeRect(0, 0, 2000, 4000),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false,
                          screen: nil)
    
    private let carbon: Carbon
    private let filename: String
    private let completion: (Result<String, Error>) -> Void
    
    init(carbon: Carbon, filename: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.carbon = carbon
        self.filename = filename
        self.completion = completion
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let carbonWebView = CarbonWebView(frame: window.contentView!.bounds, carbon: carbon, filename: filename)
        carbonWebView.carbonDelegate = self
        
        window.makeKeyAndOrderFront(nil)
        window.contentView?.addSubview(carbonWebView)
        carbonWebView.loadCarbon(isEmbeded: true)
    }
    
    // MARK: delegate methods <CarbonWebViewDelegate>
    func didFailLoadCarbon() {
        // TODO
    }
    
    func didLoadCarbon() {
        // TODO
    }
}
