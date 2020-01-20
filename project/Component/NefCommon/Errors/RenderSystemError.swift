//  Copyright © 2020 The nef Authors.

import Foundation

public enum RenderSystemError: Error {
    case persist(item: URL)
    case structure(folder: URL)
}
