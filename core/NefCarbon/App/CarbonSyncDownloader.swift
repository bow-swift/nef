//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

class CarbonSyncDownloader: CarbonDownloader, CarbonViewDelegate {
    
    private weak var view: CarbonView?

    private let semaphore: DispatchSemaphore
    private var syncResult: Result<String, CarbonError>!
    private var counter: Int = 0
    
    init(view: CarbonView) {
        self.view = view
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    // MARK: delegate <CarbonDownloader>
    func carbon(withConfiguration configuration: Carbon, filename: String) -> Result<String, CarbonError> {
        guard let view = view else { return .failure(CarbonError(filename: filename, snippet: configuration.code, error: .notFound)) }
        
        run {
            view.load(carbon: configuration, filename: "\(filename)-\(self.counter)")
            self.counter += 1
        }

        return syncResult
    }
    
    // MARK: delegate <CarbonViewDelegate>
    func didFailLoadCarbon(error: CarbonError) {
        syncResult = .failure(error)
        semaphore.signal()
    }
    
    func didLoadCarbon(filename: String) {
        syncResult = .success(filename)
        semaphore.signal()
    }
    
    // MARK: private methods <helpers>
    private func run(operation: @escaping () -> Void) {
        DispatchQueue.main.async { operation() }
        semaphore.wait()
    }
}
