//  Copyright © 2019 The nef Authors.

import Foundation

extension String {

    func clean(_ ocurrences: String...) -> String {
        return ocurrences.reduce(self) { (output, ocurrence) in
            output.replacingOccurrences(of: ocurrence, with: "")
        }
    }
}
