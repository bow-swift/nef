//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import Markup


/// Carbon view definition
protocol CarbonView: class {
    func load(carbon: Carbon, filename: String)
}

protocol CarbonViewDelegate: class {
    func didFailLoadCarbon(error: CarbonError)
    func didLoadCarbon(filename: String)
}


/// Web view where loading/downloading the carbon configuration
class CarbonWebView: WKWebView, WKNavigationDelegate, CarbonView {

    private var filename: String?
    private var carbon: Carbon?
    private var isCached: Bool = false
    weak var carbonDelegate: CarbonViewDelegate?
    
    init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(carbon: Carbon, filename: String) {
        self.filename = filename
        self.carbon = carbon
        isCached ? launchCachedRequest() : buildCache()
    }
    
    // MARK: private methods
    private func buildCache() {
        let style  = CarbonStyle(background: .bow, theme: .dracula, size: .x5, fontType: .firaCode, lineNumbers: true, watermark: true)
        let carbon = Carbon(code: "", style: style)
        let request = urlRequest(from: carbon)
        launch(carbonRequest: request)
    }
    
    private func launchCachedRequest() {
        guard let carbon = carbon else { didFailLoadingCarbonWebView(); return }
        let request = urlRequest(from: carbon)
        
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
            self.launch(carbonRequest: request)
        }
    }
    
    private func launch(carbonRequest: URLRequest) {
        loadFontsScripts()
        self.load(carbonRequest)
    }
    
    private func urlRequest(from carbon: Carbon) -> URLRequest {
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
        urlComponents.path = "/embeded"
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
        let error = CarbonError(filename: filename ?? "", snippet: carbon?.code ?? "", error: .notFound)
        carbonDelegate?.didFailLoadCarbon(error: error)
    }
    
    // MARK: javascript <helpers>
    private func carbonRectArea(in webView: WKWebView, zoom: CGFloat, completion: @escaping (WKSnapshotConfiguration?) -> Void) {
        let container = "document.getElementsByClassName('container-bg')[0]"
        let getWidth = "\(container).scrollWidth"
        let getHeight = "\(container).scrollHeight"
        
        webView.evaluateJavaScript(resetPosition + "[\(getWidth), \(getHeight)]") { (result, _) in
            guard let inset = result as? [CGFloat], inset.count == 2 else {
                completion(nil); return
            }
            
            let (w, h) = (inset[0], inset[1])
            let rect = CGRect(x: 0, y: 0, width: w * zoom, height: h * zoom)
            let configuration = WKSnapshotConfiguration()
            configuration.rect = rect
            
            completion(configuration)
        }
    }
    
    private func hideCopyButton(in webView: WKWebView) {
        let showWatermark = carbon?.style.watermark ?? false
        guard !showWatermark else { return }
        let hideCopyButton = "document.getElementsByClassName('copy-button')[0].style.display = 'none'"
        webView.evaluateJavaScript(hideCopyButton)
    }
    
    private func loadFontsScripts() {
        load(script: headersStyleScript + fontStyleScript)
    }
    
    private func injectWatermark() {
        let showWatermark = carbon?.style.watermark ?? false
        guard showWatermark else { return }
        evaluateJavaScript(injectPoweredByJS +  injectNefLogoJS)
    }
    
    // MARK: - helpers
    func load(script source: String) {
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }
}

// MARK: nef watermark
private extension CarbonWebView {
    private var injectPoweredByJS: String {
        return "var terminalTitle = document.getElementsByClassName('window-title-container')[0];" +
               "terminalTitle.firstElementChild.hidden = true;" +
               "var titleNode = document.createElement('span');" +
               "titleNode.innerHTML = 'Powered by <span style=\"color:#b2b2b2;\">nef</span>';" +
               "titleNode.setAttribute('style', 'color:#999999; font-size:13px; font-family:\"Space Mono\"; font-weight: 50');" +
               "terminalTitle.appendChild(titleNode);"
    }
    
    private var injectNefLogoJS: String {
        return "var logoButton = document.getElementsByClassName('copy-button')[0];" +
               "logoButton.firstElementChild.hidden = true;" +
               "var logoNode = document.createElement('img');" +
               "logoNode.setAttribute('src', 'data:image/png;base64,\(Assets.Base64.favicon)');" +
               "logoNode.setAttribute('height', '28');" +
               "logoButton.setAttribute('style', 'margin-top: -8px; margin-right: -9px');" +
               "logoButton.appendChild(logoNode);"
    }
}

// MARK: fonts and styles <user scripts>
private extension CarbonWebView {
    
    private var resetPosition: String {
        return "var body = document.getElementsByClassName('section')[0];" +
               "body.setAttribute('style', 'float: left;');"
    }
    
    // MARK: - Javascript for inject user scripts
    private var headersStyleScript: String {
        return "var style = document.createElement('style');"  +
               "style.setAttribute('id', '__jsx-86296889');" +
               "style.innerHTML = '\(clean(javascript: headerStyle))';" +
               "var head = document.getElementsByTagName('head')[0];"  +
               "head.appendChild(style);";
    }
    
    private var fontStyleScript: String {
        return "var style = document.createElement('style');"  +
               "style.setAttribute('id', '__jsx-3893451684');" +
               "style.innerHTML = '\(clean(javascript: fontsStyle))';" +
               "var head = document.getElementsByTagName('head')[0];"  +
               "head.appendChild(style);";
    }
    
    // MARK: - Style definitions
    private var headerStyle: String {
        return """
        html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,img,ins,kbd,q,s,samp,small,strike,strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article,aside,canvas,details,embed,figure,figcaption,footer,header,hgroup,menu,nav,output,ruby,section,summary,time,mark,audio,video{margin:0;padding:0;border:0;font-size:100%;font-weight:inherit;font-family:inherit;font-style:inherit;vertical-align:baseline;}article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block;}ol,ul{list-style:none;}blockquote,q{quotes:none;}blockquote:before,blockquote:after,q:before,q:after{content:'';content:none;}table{border-collapse:collapse;border-spacing:0;}html,body{-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;text-rendering:optimizeLegibility;background:#121212;color:white;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Ubuntu,'Helvetica Neue', sans-serif;font-weight:400;font-style:normal;text-transform:initial;-webkit-letter-spacing:initial;-moz-letter-spacing:initial;-ms-letter-spacing:initial;letter-spacing:initial;min-height:704px;}*{box-sizing:border-box;}h1,h2,h3,h4,h5,h6{font-weight:500;}a{color:inherit;-webkit-text-decoration:none;text-decoration:none;cursor:pointer;}*::selection{background:rgba(255,255,255,0.99);color:#121212;}.link{color:#fff;-webkit-text-decoration:none;text-decoration:none;padding-bottom:3px;background:linear-gradient( to right, rgba(255,255,255,0.7) 0%, rgba(255,255,255,0.7) 100% );background-size:1px 1px;background-position:0 100%;background-repeat:repeat-x;}.link:hover{color:#F8E81C;background:none;}.react-spinner{z-index:999;position:relative;width:32px;height:32px;top:50%;left:50%;}.react-spinner_bar{-webkit-animation:react-spinner_spin 1.2s linear infinite;-moz-animation:react-spinner_spin 1.2s linear infinite;-webkit-animation:react-spinner_spin 1.2s linear infinite;animation:react-spinner_spin 1.2s linear infinite;border-radius:5px;background-color:#fff;position:absolute;width:20%;height:7.8%;top:-3.9%;left:-10%;}[role='button']:focus{outline:none;}@-webkit-keyframes react-spinner_spin{0%{opacity:1;}100%{opacity:0.15;}}@keyframes react-spinner_spin{0%{opacity:1;}100%{opacity:0.15;}}@-moz-keyframes react-spinner_spin{0%{opacity:1;}100%{opacity:0.15;}}@-webkit-keyframes react-spinner_spin{0%{opacity:1;}100%{opacity:0.15;}}
        """
    }
    
    private var fontsStyle: String {
        return """
        @font-face{font-family:'Iosevka';font-display:swap;src:url('//cdn.jsdelivr.net/npm/@typopro/web-iosevka@3.7.5/TypoPRO-iosevka-term-bold.woff') format('woff');font-weight:400;font-style:normal;}@font-face{font-family:'Monoid';font-display:swap;src:url('//cdn.jsdelivr.net/npm/@typopro/web-monoid@3.7.5/TypoPRO-Monoid-Regular.woff') format('woff2'), url('//cdn.jsdelivr.net/npm/@typopro/web-monoid@3.7.5/TypoPRO-Monoid-Regular.woff') format('woff');font-weight:400;font-style:normal;}@font-face{font-family:'Fantasque Sans Mono';font-display:swap;src:url('//cdn.jsdelivr.net/npm/@typopro/web-fantasque-sans-mono@3.7.5/TypoPRO-FantasqueSansMono-Regular.woff') format('woff2'), url('//cdn.jsdelivr.net/npm/@typopro/web-fantasque-sans-mono@3.7.5/TypoPRO-FantasqueSansMono-Regular.woff') format('woff');font-weight:400;font-style:normal;}@font-face{font-family:'Hack';font-display:swap;src:url('//cdn.jsdelivr.net/font-hack/2.020/fonts/woff2/hack-regular-webfont.woff2?v=2.020') format('woff2'), url('//cdn.jsdelivr.net/font-hack/2.020/fonts/woff/hack-regular-webfont.woff?v=2.020') format('woff');font-weight:400;font-style:normal;}@font-face{font-family:'Fira Code';font-display:swap;src:url('//cdn.rawgit.com/tonsky/FiraCode/1.204/distr/woff2/FiraCode-Regular.woff2') format('woff2'), url('//cdn.rawgit.com/tonsky/FiraCode/1.204/distr/woff/FiraCode-Regular.woff') format('woff');font-weight:400;font-style:normal;}@font-face{font-family:'IBM Plex Mono';font-display:swap;font-style:italic;font-weight:500;src:local('IBM Plex Mono Medium Italic'),local('IBMPlexMono-MediumItalic'), url(https://fonts.gstatic.com/s/ibmplexmono/v2/-F6sfjptAgt5VM-kVkqdyU8n1ioSJlR1gMoQPttozw.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2191,U + 2193,U + 2212, U + 2215,U + FEFF,U + FFFD;}@font-face{font-family:'Anonymous Pro';font-display:swap;font-style:normal;font-weight:400;src:local('Anonymous:Pro Regular'),local('AnonymousPro-Regular'), url(//fonts.gstatic.com/s/anonymouspro/v11/Zhfjj_gat3waL4JSju74E3n3cbdKJftHIk87C9ihfO8.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2212,U + 2215;}@font-face{font-family:'Droid Sans Mono';font-display:swap;font-style:normal;font-weight:400;src:local('Droid:Sans Mono Regular'),local('DroidSansMono-Regular'), url(//fonts.gstatic.com/s/droidsansmono/v9/ns-m2xQYezAtqh7ai59hJVlgUn8GogvcKKzoM9Dh-4E.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2212,U + 2215;}@font-face{font-family:'Inconsolata';font-display:swap;font-style:normal;font-weight:400;src:local('Inconsolata:Regular'),local('Inconsolata-Regular'), url(//fonts.gstatic.com/s/inconsolata/v16/BjAYBlHtW3CJxDcjzrnZCIgp9Q8gbYrhqGlRav_IXfk.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2212,U + 2215;}@font-face{font-family:'Source Code Pro';font-display:swap;font-style:normal;font-weight:400;src:local('Source:Code Pro'),local('SourceCodePro-Regular'), url(//fonts.gstatic.com/s/sourcecodepro/v7/mrl8jkM18OlOQN8JLgasD5bPFduIYtoLzwST68uhz_Y.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2212,U + 2215;}@font-face{font-family:'Ubuntu Mono';font-display:swap;font-style:normal;font-weight:400;src:local('Ubuntu:Mono'),local('UbuntuMono-Regular'), url(//fonts.gstatic.com/s/ubuntumono/v7/ViZhet7Ak-LRXZMXzuAfkYgp9Q8gbYrhqGlRav_IXfk.woff2) format('woff2');unicode-range:U + 0000-00ff,U + 0131,U + 0152-0153,U + 02bb-02bc,U + 02c6,U + 02da, U + 02dc,U + 2000-206f,U + 2074,U + 20ac,U + 2122,U + 2212,U + 2215;}@font-face{font-family:'Space Mono';font-display:swap;font-style:normal;font-weight:400;src:local('Space Mono'),local('SpaceMono-Regular'), url(https://fonts.gstatic.com/s/spacemono/v2/i7dPIFZifjKcF5UAWdDRYEF8RQ.woff2) format('woff2');unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC, U+2000-206F,U+2074,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD;}
        """
    }
    
    // MARK: - internal helpers
    func clean(javascript: String) -> String {
        return javascript.replacingOccurrences(of: "'", with: "\\\'")
    }
}
