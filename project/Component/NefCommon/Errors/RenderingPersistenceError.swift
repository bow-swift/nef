//  Copyright © 2020 The nef Authors.

import Foundation

public enum RenderingPersistenceError: Error {
    case persist(item: URL)
    case structure(folder: URL)
    case extractValue
}
