import NefModels
import nef

public enum CommandOutcome {
    case successful(String)
    case failed(String, error: nef.Error)
}

extension CommandOutcome {
    public var progressDescription: String {
        switch self {
        case .successful(let info):
            return info
        
        case let .failed(info, error: error):
            return "\(info) failed with error: \(error)"
        }
    }
}
