//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol XcodePlaygroundSystem {
    func xcodeprojs(at folder: URL) -> EnvIO<FileSystem, XcodePlaygroundSystemError, NEA<URL>>
    func xcworkspaces(at folder: URL) -> EnvIO<FileSystem, XcodePlaygroundSystemError, NEA<URL>>
    func linkedPlaygrounds(at folder: URL) -> EnvIO<FileSystem, XcodePlaygroundSystemError, NEA<URL>>
    func playgrounds(at folder: URL) -> EnvIO<FileSystem, XcodePlaygroundSystemError, NEA<URL>>
    func pages(in playground: URL) -> EnvIO<FileSystem, XcodePlaygroundSystemError, NEA<URL>>
}
