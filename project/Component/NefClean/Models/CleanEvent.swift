import NefModels

public enum CleanEvent {
    case cleaningPlayground(String)
}

extension CleanEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case let .cleaningPlayground(name):
            return "\t• Cleaning playground '\(name)'..."
        }
    }
}
