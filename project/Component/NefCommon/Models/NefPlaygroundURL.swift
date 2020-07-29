//  Copyright © 2020 The nef Authors.

import Foundation

public struct NefPlaygroundURL {
    public let project: URL
    public var name: String { project.lastPathComponent.removeExtension }
    
    public init(project: URL) {
        self.project = project.deletingPathExtension().appendingPathExtension("app")
    }
    
    public init(folder: URL, name: String) {
        self.project = folder.appendingPathComponent("\(name.removeExtension).app")
    }
    
    public func appending(_ component: Component) -> URL {
        project.appendingPathComponent(component.pathComponent)
    }
    
    public func appending(pathComponent: String, in component: Component) -> URL {
        project.appendingPathComponent(component.pathComponent).appendingPathComponent(pathComponent.removeExtension).appendingPathExtension(component.extension)
    }
    
    public func appending(pathComponent: String, extension: String, in component: Component) -> URL {
        project.appendingPathComponent(component.pathComponent).appendingPathComponent(pathComponent.removeExtension).appendingPathExtension(`extension`)
    }
    
    public enum Component: String {
        case nef
        case derivedData
        case log
        case build
        case fw
        case contentFiles
        case launcher
        case cocoapodsTemplate = "cocoapods"
        case carthageTemplate  = "carthage"
        case spmTemplate = "spm"
        
        public var pathComponent: String {
            switch self {
            case .nef:           return rawValue
            case .derivedData:   return "\(Component.nef.pathComponent)/\(rawValue)"
            case .log:           return "\(Component.nef.pathComponent)/\(rawValue)"
            case .build:         return "\(Component.nef.pathComponent)/\(rawValue)"
            case .fw:            return "\(Component.build.pathComponent)/\(rawValue)"
            case .contentFiles:      return "Contents/MacOS"
            case .launcher:          return "\(Component.contentFiles.pathComponent)/\(rawValue)"
            case .cocoapodsTemplate: return "\(Component.contentFiles.pathComponent)/\(rawValue)"
            case .carthageTemplate:  return "\(Component.contentFiles.pathComponent)/\(rawValue)"
            case .spmTemplate:       return "\(Component.contentFiles.pathComponent)/\(rawValue)"
            }
        }
        
        var `extension`: String {
            switch self {
            case .log:   return "log"
            case .build: return "swift"
            case .fw:    return "framework"
            default: return ""
            }
        }
    }
}
