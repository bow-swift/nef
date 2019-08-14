//  Copyright © 2019 The nef Authors.

import Foundation

public class File {
    private let fileManager = FileManager.default
    
    public init() {}
    
    @discardableResult
    public func createFolder(path: String, name: String) -> Bool {
        let folderPath = "\(path)/\(name)"
        guard !fileManager.fileExists(atPath: folderPath) else { return false }
        let created: Void? = try? fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        
        return created != nil
    }
    
    @discardableResult
    public func copy(_ itemPath: String, to outputPath: String, override: Bool = true) -> String? {
        let itemURL = URL(fileURLWithPath: itemPath)
        let outputURL = URL(fileURLWithPath: "\(outputPath)/\(itemPath.filename)")
        
        if override { remove(filePath: outputURL.path) }
        let copied: Void? = try? fileManager.copyItem(at: itemURL, to: outputURL)
        
        return copied != nil ? outputURL.path : nil
    }
    
    private func remove(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        _ = try? fileManager.removeItem(at: fileURL)
    }
}
