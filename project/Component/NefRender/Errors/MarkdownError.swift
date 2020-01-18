//  Copyright © 2019 The nef Authors.

import Foundation

public enum RenderError: Error {
    case renderContent
    case render(page: URL)
    case renderPlaygrounds
    case getPlaygrounds(folder: URL)
    case getPages(playground: URL)
}

extension RenderError {
    var information: String {
        switch self {
        case .renderContent:
            return "can not render content"
        case .render(let page):
            return "can not render page '\(page.path)'"
        case .renderPlaygrounds:
            return "can not render playgrounds"
        case .getPlaygrounds(let folder):
            return "could not get playgrounds at '\(folder.path)'"
        case .getPages(let playground):
            return "could not get pages at '\(playground.path)'"
        }
    }
}
