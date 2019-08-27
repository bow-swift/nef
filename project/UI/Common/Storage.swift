//  Copyright © 2019 The nef Authors.

import Foundation

public enum StorageError: Error {
    case exist
    case notCreated
    case notCopied
}

public class Storage {
    private let fileManager = FileManager.default
    
    public init() {}
    
    @discardableResult
    public func createFolder(path folderPath: String) -> Result<String, StorageError> {
        guard !fileManager.fileExists(atPath: folderPath) else { return .failure(.exist) }
        
        do {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            return .success(folderPath)
        } catch {
            return .failure(.notCreated)
        }
    }
    
    @discardableResult
    public func createFile(withContent content: String, atPath filePath: String) -> Result<String, StorageError> {
        guard !fileManager.fileExists(atPath: filePath) else { return .failure(.exist) }
        guard let content = content.data(using: .utf8),
              fileManager.createFile(atPath: filePath, contents: content, attributes: nil) else { return .failure(.notCreated) }
        
        return .success(filePath)
    }
    
    @discardableResult
    public func copy(_ itemPath: String, to outputPath: String, override: Bool = true) -> Result<String, StorageError> {
        let itemURL = URL(fileURLWithPath: itemPath)
        let outputURL = URL(fileURLWithPath: "\(outputPath)/\(itemPath.filename)")
        
        if override {
            remove(filePath: outputURL.path)
        }
        
        do {
            try fileManager.copyItem(at: itemURL, to: outputURL)
            return .success(outputURL.path)
        } catch {
            return .failure(.notCopied)
        }
    }
    
    public func remove(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        _ = try? fileManager.removeItem(at: fileURL)
    }
}
