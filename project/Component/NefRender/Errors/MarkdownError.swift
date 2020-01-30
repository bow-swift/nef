//  Copyright © 2019 The nef Authors.

import Foundation

public enum RenderError: Error {
    case content
    case page(_ page: URL)
    case playground(_ playground: URL)
    case playgrounds
    case workspace(_ workspace: URL)
    case getPlaygrounds(folder: URL)
    case getPages(playground: URL)
    case getWorkspace(folder: URL)
}

extension RenderError {
    var information: String {
        switch self {
        case .content:
            return "can not render content"
        case .page(let page):
            return "can not render page '\(page.path)'"
        case .playground(let playground):
            return "can not render playground '\(playground.path)'"
        case .workspace(let workspace):
            return "can not render workspace '\(workspace.path)'"
        case .playgrounds:
            return "can not render playgrounds"
        case .getPlaygrounds(let folder):
            return "could not get playgrounds at '\(folder.path)'"
        case .getPages(let playground):
            return "could not get pages at '\(playground.path)'"
        case .getWorkspace(let folder):
            return "could not extract only xcworkspace at '\(folder.path)'"
        }
    }
}
