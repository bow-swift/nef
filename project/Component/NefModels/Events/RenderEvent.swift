public enum RenderEvent {
    case processingPage(String)
    case gettingPagesFromPlayground(String)
    case gettingPlaygrounds(String)
}

extension RenderEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        
        case let .processingPage(name):
            return "\t• Processing page \(name)"
            
        case let .gettingPagesFromPlayground(name):
            return "Getting pages in playground \(name)"
            
        case let .gettingPlaygrounds(name):
            return "Getting playgrounds in \(name)"
        }
    }
}
