//  Copyright © 2019 The nef Authors.

import Markup

class CarbonAppDownloader: CarbonDownloader, CarbonViewDelegate {
    
    private weak var view: CarbonView?
    private var callback: ((Result<String, CarbonError>) -> Void)?
    
    init(view: CarbonView) {
        self.view = view
    }
    
    // MARK: delegate <CarbonDownloader>
    func carbon(withConfiguration configuration: Carbon, filename: String, completion: @escaping (Result<String, CarbonError>) -> Void) {
        self.callback = completion
        view?.load(carbon: configuration, filename: filename, isEmbeded: true)
    }
    
    // MARK: delegate <CarbonViewDelegate>
    func didFailLoadCarbon(error: CarbonError) {
        callback?(.failure(error))
    }
    
    func didLoadCarbon(filename: String) {
        callback?(.success(filename))
    }
}
