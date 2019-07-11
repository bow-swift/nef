//  Copyright © 2019 The nef Authors.

import AppKit

public extension NSImage {
    
    func writeToFile(file: String, atomically: Bool, usingType type: NSBitmapImageRep.FileType) -> Bool {
        let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        guard let imageData = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: type, properties: properties) else { return false }
        
        let data = NSData(data: fileData)
        return data.write(toFile: file, atomically: atomically)
    }
}
