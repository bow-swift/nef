//  Copyright © 2019 The nef Authors.

import Foundation
import BowEffects
import NefMarkdown

extension MacFileSystem: MarkdownSystem {
    func write(content: String, toFile file: URL) -> IO<MarkdownSystemError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: file.path, atomically: true, encoding: .utf8)
            } catch {
                throw MarkdownSystemError.write(file: file.path)
            }
        }
    }
    
    func createDirectory(at url: URL) -> IO<MarkdownSystemError, ()> {
        FileManager.default.createDirectoryIO(at: url, withIntermediateDirectories: true)
                           .mapLeft { _ in .create(item: url) }
    }
    
    func removeFile(at url: URL) -> IO<MarkdownSystemError, ()> {
        FileManager.default.removeItemIO(at: url).mapLeft { _ in .remove(item: url) }
    }
}
