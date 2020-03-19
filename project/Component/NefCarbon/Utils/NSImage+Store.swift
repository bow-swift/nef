//  Copyright © 2019 The nef Authors.

import AppKit
import NefCore

public extension NSImage {
    
    func image(usingType type: NSBitmapImageRep.FileType, metadata: String) -> NefCore.Image? {
        let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        guard let imageData = tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: imageData),
              let fileData = imageRep.representation(using: type, properties: properties) else { return nil }
        
        let nsdata = NSData(data: fileData).updateExif(withText: metadata)
        return .data(Data(referencing: nsdata))
    }
}

extension NSData {
    
    func updateExif(withText content: String) -> NSData {
        let dataWithEXIF = NSMutableData(data: self as Data) as CFMutableData
        
        guard let imageRef = CGImageSourceCreateWithData(self as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageRef, 0, nil),
              let uti = CGImageSourceGetType(imageRef),
              let destination = CGImageDestinationCreateWithData(dataWithEXIF, uti, 1, nil),
              let metadataInfoTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceExif, kCGImageMetadataPrefixExif, kCGImagePropertyPNGDescription, .string, content as CFString),
              let metadataUserTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceExif, kCGImageMetadataPrefixExif, kCGImagePropertyPNGAuthor, .string, "nef" as CFString) else { return self }
        
        
        let metadata = CGImageMetadataCreateMutable()
        let exifInfoPath = "\(kCGImageMetadataPrefixExif):\(kCGImagePropertyPNGDescription)" as CFString
        let exifUserPath = "\(kCGImageMetadataPrefixExif):\(kCGImagePropertyPNGAuthor)" as CFString
        
        CGImageMetadataSetTagWithPath(metadata, nil, exifInfoPath, metadataInfoTag)
        CGImageMetadataSetTagWithPath(metadata, nil, exifUserPath, metadataUserTag)
        CGImageDestinationAddImageAndMetadata(destination, image, metadata, nil)
        CGImageDestinationFinalize(destination)

        return dataWithEXIF as NSData
    }
}
