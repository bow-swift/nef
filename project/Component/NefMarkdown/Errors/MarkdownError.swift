//  Copyright © 2019 The nef Authors.

import Foundation

public enum MarkdownError: Error {
    case renderPage
    case create(file: URL)
    case structure
}

extension MarkdownError {
    var information: String {
        switch self {
        case .renderPage:
            return "can not render input page into markdown file"
        case .create(let file):
            return "can not create the file '\(file.path)'"
        case .structure:
            return "could not create project structure"
        }
    }
}
