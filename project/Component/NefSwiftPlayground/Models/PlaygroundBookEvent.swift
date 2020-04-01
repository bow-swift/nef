import NefModels

public enum PlaygroundBookEvent {
    case cleanup
    case creatingStructure(String)
    case downloadingDependencies
    case gettingModules
    case buildingPlayground
}

extension PlaygroundBookEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case .cleanup:
            return "Cleaning up generated files for building"
        case .creatingStructure(let name):
            return "Creating swift playground structure (\(name))"
        case .downloadingDependencies:
            return "Downloading dependencies..."
        case .gettingModules:
            return "Getting modules from repositories..."
        case .buildingPlayground:
            return "Building Swift Playground..."
        }
    }
}
