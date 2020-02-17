//  Copyright © 2020 The nef Authors.

import Foundation

public struct NefURL {
    public let project: URL
    public let action: Action
    
    public init(project: URL, action: Action) {
        self.project = project
        self.action = action
    }
    
    public var url: URL {
        project.appendingPathComponent(action.pathComponent)
    }
    
    public func appending(_ component: String) -> URL {
        self.url.appendingPathComponent(component.removeExtension).appendingPathExtension(action.extension)
    }
    
    public enum Action: String {
        case root = "nef"
        case derivedData
        case log
        case build
        case fw
        
        public var pathComponent: String {
            switch self {
            case .root:        return rawValue
            case .derivedData: return "\(Action.root.pathComponent)/\(rawValue)"
            case .log:         return "\(Action.root.pathComponent)/\(rawValue)"
            case .build:       return "\(Action.root.pathComponent)/\(rawValue)"
            case .fw:          return "\(Action.build.pathComponent)/\(rawValue)"
            }
        }
    }
}

// MARK: - helpers

fileprivate extension NefURL.Action {
    
    var `extension`: String {
        switch self {
        case .root:        return ""
        case .derivedData: return ""
        case .log:         return "log"
        case .build:       return "swift"
        case .fw:          return "framework"
        }
    }
}
