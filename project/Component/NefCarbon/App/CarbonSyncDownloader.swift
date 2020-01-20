//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import BowEffects

class CarbonSyncDownloader: CarbonDownloader, CarbonViewDelegate {
    private weak var view: CarbonView?

    private let multiFiles: Bool
    private let semaphore: DispatchSemaphore
    private var syncResult: Result<String, CarbonError>!
    private var counter: Int = 0
    
    init(view: CarbonView, multiFiles: Bool) {
        self.view = view
        self.multiFiles = multiFiles
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    // MARK: delegate <CarbonDownloader>
    func carbon(withConfiguration configuration: CarbonModel, filename: String) -> Result<String, CarbonError> {
        guard let view = view else { return .failure(CarbonError(filename: filename, snippet: configuration.code, cause: .notFound)) }
        
        run {
            let filename = self.multiFiles ? "\(filename)-\(self.counter)" : filename
            view.load(carbon: configuration, filename: filename)
            self.counter += 1
        }

        return syncResult
    }
    
    func carbon(configuration: CarbonModel) -> IO<CarbonError, Image> {
        fatalError()
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
