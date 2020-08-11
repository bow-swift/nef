import NefModels

public enum PlaygroundBookEvent {
    case cleanup
    case creatingStructure(String)
    case downloadingDependencies
    case creatingPackageGraph
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
        case .creatingPackageGraph:
            return "Creating package graph..."
        case .gettingModules:
            return "Getting modules from repositories..."
        case .buildingPlayground:
            return "Building Swift Playground..."
        }
    }
    
    public var currentStep: UInt {
        switch self {
        case .cleanup:
            return 1
        case .creatingStructure:
            return 2
        case .downloadingDependencies:
            return 3
        case .creatingPackageGraph:
            return 4
        case .gettingModules:
            return 5
        case .buildingPlayground:
            return 6
        }
    }
    
    public var totalSteps: UInt { 6 }
}
