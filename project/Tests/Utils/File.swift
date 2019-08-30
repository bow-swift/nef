//  Copyright © 2019 The nef Authors.

import Foundation

class File {
    
    func loadJSON(fileName: String) -> [AnyHashable: Any]? {
        guard let data: NSData = readData(in: fileName, extension: "json"),
              let dictionary = try? JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [AnyHashable: Any] else {
                print("[!] error: unable to parse \(fileName).json")
                return nil
        }
        
        return dictionary
    }
    
    func loadRaw(fileName: String, extension: String) -> String? {
        return readData(in: fileName, extension: `extension`)
    }
    
    // MARK: helpers
    private var bundle: Bundle { return Bundle(for: type(of: self)) }
    
    private func readData(in fileName: String, extension: String) -> NSData? {
        guard let url = bundle.url(forResource: fileName, withExtension: `extension`) else { return nil }
        return NSData(contentsOf: url)
    }
    
    private func readData(in fileName: String, extension: String) -> String? {
        guard let url = bundle.url(forResource: fileName, withExtension: `extension`) else { return nil }
        return try? String(contentsOf: url)
    }
}
