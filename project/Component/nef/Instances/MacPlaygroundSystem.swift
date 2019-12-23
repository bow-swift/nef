//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

class MacPlaygroundSystem: PlaygroundSystem {
    private let fileManager = FileManager.default
    
    func name(_ playground: URL) -> IO<PlaygroundSystemError, String> {
        fatalError()
    }
    
    func unique(playground: URL, in path: URL) -> IO<PlaygroundSystemError, URL> {
        fatalError()
    }
    
    func playgrounds(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>> {
        return self.xcworkspaces(at: folder).flatMap { xcworkspaces in
            print(xcworkspaces)
            return IO.pure(xcworkspaces)
        }^
    }
    
    func pages(in playground: URL) -> IO<PlaygroundSystemError, NEA<URL>> {
        fatalError()
    }
    
    // MARK: - helpers
    private func xcworkspaces(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>> {
        func isDependency(xcworkspace: URL) -> Bool {
            return xcworkspace.path.contains("/Pods/") || xcworkspace.path.contains("/Carthage/")
        }
        
        guard let enumerator = fileManager.enumerator(at: folder, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return IO.raiseError(PlaygroundSystemError.playgrounds())^
        }
        
        let xcworkspaces = enumerator.compactMap { file -> URL? in
            guard let fileURL = file as? URL, fileURL.pathExtension == "pbxproj" else { return nil }
            let xcodeproj = fileURL.deletingLastPathComponent()
            let xcworkspace = xcodeproj.deletingPathExtension().appendingPathExtension("xcworkspace")
            return fileManager.fileExists(atPath: xcworkspace.path) && !isDependency(xcworkspace: xcworkspace) ? xcworkspace : nil
        }
        
        if let last = xcworkspaces.last {
            return IO.pure(NEA(head: last, tail: xcworkspaces.dropLast()))^
        } else {
            return IO.raiseError(PlaygroundSystemError.playgrounds(information: "not found any valid workspace in '\(folder.path)'"))^
        }
    }
}
