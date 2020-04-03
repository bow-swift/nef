import BowEffects

public protocol OutcomeReport {
    func notify<E: Error>(_ outcome: String) -> IO<E, Void>
}

public extension OutcomeReport {
    func success<E: Error>(_ info: String) -> IO<E, Void> {
        self.notify("🙌 \(info)")
    }
    
    func failure<E: Error>(_ info: String, error: E) -> IO<E, Void> {
        self.notify("☠️ \(info) failed with error:\n\(error)")
    }
}
