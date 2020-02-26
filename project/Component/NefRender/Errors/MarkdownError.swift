//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon

public enum RenderError: Error {
    case content(info: ErrorStringConvertible? = nil)
    case page(_ page: URL)
    case playground(_ playground: URL)
    case playgrounds
    case workspace(_ workspace: URL, info: ErrorStringConvertible? = nil)
    case getPlaygrounds(folder: URL)
    case getPages(playground: URL)
    case getWorkspace(folder: URL)
}

extension RenderError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .content(let info):
            return "Cannot render content".appending(error: info)
        case .page(let page):
            return "Cannot render page '\(page.path)'"
        case .playground(let playground):
            return "Cannot render playground '\(playground.path)'"
        case .workspace(let workspace, let info):
            return "Cannot render workspace '\(workspace.path)'".appending(error: info)
        case .playgrounds:
            return "Cannot render playgrounds"
        case .getPlaygrounds(let folder):
            return "Could not get playgrounds at '\(folder.path)'"
        case .getPages(let playground):
            return "Could not get pages at '\(playground.path)'"
        case .getWorkspace(let folder):
            return "Could not extract only xcworkspace at '\(folder.path)'"
        }
    }
}
