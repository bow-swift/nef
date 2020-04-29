//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

final class UnixFileSystem: NefCommon.FileSystem {
    
    func createDirectory(atPath path: String) -> IO<FileSystemError, ()> {
        FileManager.default.createDirectoryIO(atPath: path, withIntermediateDirectories: true)
                           .mapError { _ in .create(item: path) }
    }
    
    func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.copyItemIO(atPath: atPath, toPath: toPath)
                           .mapError { _ in .copy(from: atPath, to: toPath) }
    }
    
    func remove(itemPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(atPath: itemPath)
                           .mapError { _ in .remove(item: itemPath) }
    }
    
    func items(atPath path: String, recursive: Bool) -> IO<FileSystemError, [String]> {
        func items(atPath: String) -> IO<FileSystemError, [String]> {
            FileManager.default.contentsOfDirectoryIO(atPath: atPath)
                .mapError { _ in .get(from: atPath) }
                .map { files in files.map({ file in "\(atPath)/\(file)"}) }^
        }
        
        func itemsRecursive(atPath: String) -> IO<FileSystemError, [String]> {
            IO.invoke {
                let items = FileManager.default.enumerator(atPath: atPath)?
                                .compactMap { $0 as? String }
                                .map { file in "\(atPath)/\(file)" }
                return items ?? []
            }^
        }
        
        return recursive ? itemsRecursive(atPath: path) : items(atPath: path)
    }
    
    func readFile(atPath path: String) -> IO<FileSystemError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: path)
            } catch {
                throw FileSystemError.read(file: path)
            }
        }
    }
    
    func write(content: String, toFile path: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                throw FileSystemError.write(file: path)
            }
        }
    }
    
    func write(content: Data, toFile path: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            do {
                try content.write(to: URL(fileURLWithPath: path), options: .atomic)
            } catch {
                throw FileSystemError.write(file: path)
            }
        }
    }
    
    func exist(itemPath: String) -> Bool {
        FileManager.default.fileExists(atPath: itemPath)
    }
    
    func temporalDirectory() -> URL {
        FileManager.default.temporaryDirectory
    }
}
