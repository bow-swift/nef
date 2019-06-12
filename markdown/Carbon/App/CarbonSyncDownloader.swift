//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

class CarbonSyncDownloader: CarbonDownloader, CarbonViewDelegate {
    
    private weak var view: CarbonView?
    private let semaphore: DispatchSemaphore
    private var syncResult: Result<String, CarbonError>!
    
    init(view: CarbonView) {
        self.view = view
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    // MARK: delegate <CarbonDownloader>
    func carbon(withConfiguration configuration: Carbon, filename: String) -> Result<String, CarbonError> {
        DispatchQueue.main.async {
            self.view?.load(carbon: configuration, filename: filename, isEmbeded: true)
        }
        semaphore.wait()
        
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
}
