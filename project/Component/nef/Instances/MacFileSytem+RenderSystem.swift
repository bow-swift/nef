//  Copyright © 2019 The nef Authors.

import Foundation
import BowEffects
import NefRender

extension MacFileSystem: RenderSystem {
    func write(content: String, toFile file: URL) -> IO<RenderSystemError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: file.path, atomically: true, encoding: .utf8)
            } catch {
                throw RenderSystemError.write(file: file.path)
            }
        }
    }
    
    func createDirectory(at url: URL) -> IO<RenderSystemError, ()> {
        FileManager.default.createDirectoryIO(at: url, withIntermediateDirectories: true)
                           .mapLeft { _ in .create(item: url) }
    }
    
    func removeFile(at url: URL) -> IO<RenderSystemError, ()> {
        FileManager.default.removeItemIO(at: url).mapLeft { _ in .remove(item: url) }
    }
    
    func exist(directory: URL) -> Bool {
        FileManager.default.fileExists(atPath: directory.path)
    }
}
