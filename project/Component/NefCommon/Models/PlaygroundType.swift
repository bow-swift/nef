//  Copyright © 2019 The nef Authors.

import Foundation

public protocol PlaygroundType {}
public protocol Project: PlaygroundType {}
public protocol Page: PlaygroundType {}

public struct PlaygroundURL<PlaygroundType> {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
}
