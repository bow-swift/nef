//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import NefModels

internal class CarbonWebView: WKWebView, WKNavigationDelegate, NefModels.CarbonView {
    private let code: String
    private var state: CarbonStyle
    weak var loadingView: CarbonLoadingView?

    init(code: String, state: CarbonStyle) {
        self.code = code
        self.state = state
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard newSuperview != nil else { return }
        
        if #available(OSX 10.15, *) {
            isHorizontalContentSizeConstraintActive = false
            isVerticalContentSizeConstraintActive = false
        }
        
        loadCarbonWebView()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil // disabled user interaction
    }
    
    private func loadCarbonWebView() {
        loadingView?.show()
        
        let carbon = CarbonModel(code: code, style: state)
        let request = CarbonViewer.urlRequest(from: carbon)
        load(request)
    }
    
    // MARK: delegate <NefModels.CarbonView>
    public func update(state: CarbonStyle) {
        guard self.state != state else { return }
        self.state = state
        loadCarbonWebView()
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingView?.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resetPosition { [weak self] in self?.loadingView?.hide() }
    }
    
    // MARK: javascript <helpers>
    private func resetPosition(completionHandler: @escaping () -> Void) {
        let javaScript = "var html = document.getElementsByTagName('html')[0];" +
                         "var body = document.getElementsByTagName('body')[0];" +
                         "var main = document.getElementsByClassName('main')[0];" +
                         "var container = document.getElementsByClassName('export-container')[0];" +
                         "main.replaceWith(container);" +
                         "container.className = 'export-container';" +
                         "container.setAttribute('style', 'position: absolute; height: 0px; width: 100%; float: left; top: 0px;');" +
                         "html.setAttribute('style', 'min-height: 0px; margin: 0px; background: #\(state.background.hex);');" +
                         "body.setAttribute('style', 'min-height: 0px; margin: 0px; background: transparent;');"
        
        evaluateJavaScript(javaScript) { (_, _) in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(500), execute: completionHandler)
        }
    }
}
