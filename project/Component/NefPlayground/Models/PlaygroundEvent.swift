import NefModels

public enum PlaygroundEvent {
    case downloadingTemplate(String)
    case resolvingDependencies(String)
    case linkingPlaygrounds(String)
}

extension PlaygroundEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case let .downloadingTemplate(output):
            return "Downloading playground template '\(output)'"
            
        case let .resolvingDependencies(name):
            return "Resolving dependencies '\(name)'"
            
        case let .linkingPlaygrounds(name):
            return "Linking playgrounds '\(name)'"
        }
    }
}
