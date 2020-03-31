import NefModels

public enum CompilerEvent {
    case buildingWorkspace(String)
    case buildingPlayground(String)
    case compilingPage(String)
}

extension CompilerEvent: CustomProgressDescription {
    
    public var progressDescription: String {
        switch self {
        
        case let .buildingWorkspace(name):
            return "Building workspace '\(name)'"
        
        case let .buildingPlayground(name):
            return "Building playground '\(name)'"
            
        case let .compilingPage(name):
            return "\t• Compiling page '\(name)'"
        }
    }
}
