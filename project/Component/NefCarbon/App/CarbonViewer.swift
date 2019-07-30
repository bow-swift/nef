//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

public enum CarbonViewer {
    
    public static func urlRequest(from carbon: Carbon) -> URLRequest {
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
        urlComponents.queryItems = [backgroundColorItem, themeItem, windowsThemeItem, languageItem, dropShadowItem, shadowYoffsetItem, shadowBlurItem, windowsControlItem, autoAdjustWidthItem, verticalPaddingItem, horizontalPaddingItem, lineNumbersItem, fontItem, fontSizeItem, lineHeightItem, exportSizeCondition, exportSize, carbonWatermarkItem, codeItem]
        
        let url = urlComponents.url?.absoluteString.urlEncoding ?? "https://github.com/bow-swift/nef"
        return URLRequest(url: URL(string: url)!)
    }
}
