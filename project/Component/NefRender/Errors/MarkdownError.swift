//  Copyright © 2019 The nef Authors.

import Foundation

public enum RenderError: Error {
    case content
    case page(_ page: URL)
    case playground(_ playground: URL)
    case playgrounds
    case workspace(_ workspace: URL, info: String = "")
    case getPlaygrounds(folder: URL)
    case getPages(playground: URL)
    case getWorkspace(folder: URL)
}

extension RenderError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .content:
            return "Can not render content"
        case .page(let page):
            return "Can not render page '\(page.path)'"
        case .playground(let playground):
            return "Can not render playground '\(playground.path)'"
        case .workspace(let workspace, let info):
            return "Can not render workspace '\(workspace.path)'\(info.isEmpty ? "" : ". \n  Reason: \(info.description.firstLowercased)")"
        case .playgrounds:
            return "Can not render playgrounds"
        case .getPlaygrounds(let folder):
            return "Could not get playgrounds at '\(folder.path)'"
        case .getPages(let playground):
            return "Could not get pages at '\(playground.path)'"
        case .getWorkspace(let folder):
            return "Could not extract only xcworkspace at '\(folder.path)'"
        }
    }
}
