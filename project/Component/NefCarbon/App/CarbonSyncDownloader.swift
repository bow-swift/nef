//  Copyright © 2019 The nef Authors.

import Foundation
import NefCore
import NefModels
import Bow
import BowEffects

class CarbonSyncDownloader: CarbonDownloader {
    private let view: CarbonView
    
    init(view: CarbonView) {
        self.view = view
    }
    
    // MARK: delegate <CarbonDownloader>
    func carbon(configuration: CarbonModel) -> IO<CarbonError, Image> {
        let image = IO<CarbonError, Image>.var()
        
        return binding(
                     continueOn(.main),
            image <- self.load(carbon: configuration),
        yield: image.get)^
    }
    
    // MARK: private <helpers>
    private func load(carbon: CarbonModel) -> IO<CarbonError, Image> {
        IO.async { callback in
            self.view.load(carbon: carbon, callback: callback)
        }^
    }
}
