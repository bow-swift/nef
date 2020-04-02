public enum JekyllEvent {
    case buildingMainPage(String)
    case buildingSidebar(String)
}

extension JekyllEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case let .buildingMainPage(name):
            return "Building main page '\(name)'"
        case let .buildingSidebar(name):
            return "Building sidebar '\(name)'"
        }
    }
}
