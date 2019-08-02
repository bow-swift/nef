//  Copyright © 2019 The nef Authors.

import Foundation

public struct Carbon: Codable, Equatable {
    public let code: String
    public let style: CarbonStyle
    
    public init(code: String, style: CarbonStyle) {
        self.code = code
        self.style = style
    }
}

// MARK: - Style
public struct CarbonStyle: Codable, Equatable {
    public let background: Color
    public let size: Size
    public let theme: Theme
    public let fontType: Font
    public let lineNumbers: Bool
    public let watermark: Bool
    
    public init(background: Color, theme: Theme, size: Size, fontType: Font, lineNumbers: Bool, watermark: Bool) {
        self.background = background
        self.theme = theme
        self.size = size
        self.fontType = fontType
        self.lineNumbers = lineNumbers
        self.watermark = watermark
    }
    
    public enum Size: Double, Codable, Equatable, CaseIterable {
        case x1 = 1
        case x2 = 2
        case x3 = 3
        case x4 = 4
        case x5 = 5
    }
    
    public enum Theme: String, Codable, Equatable, CaseIterable {
        case cobalt
        case blackboard
        case dracula
        case duotone = "duotone-dark"
        case hopscotch
        case lucario
        case material
        case monokai
        case nord
        case oceanicNext = "oceanic-next"
        case oneDark = "one-dark"
        case panda = "panda-syntax"
        case paraiso = "paraiso-dark"
        case seti
        case purple = "shades-of-purple"
        case solarized = "solarized dark"
        case tomorrow = "tomorrow-night-bright"
        case twilight
        case verminal
        case vscode
        case zenburn
    }
    
    public enum Font: String, Codable, Equatable, CaseIterable {
        case firaCode = "Fira Code"
        case hack = "Hack"
        case inconsolata = "Inconsolata"
        case iosevka = "Iosevka"
        case monoid = "Monoid"
        case anonymous = "Anonymous Pro"
        case sourceCodePro = "Source Code Pro"
        case darkMono = "dm"
        case droidMono = "Droid Sans Mono"
        case fantasqueMono = "Fantasque Sans Mono"
        case ibmPlexMono = "IBM Plex Mono"
        case spaceMono = "Space Mono"
        case ubuntuMono = "Ubuntu Mono"
    }
    
    public struct Color: CustomStringConvertible, Codable, Equatable {
        public let r: UInt8
        public let g: UInt8
        public let b: UInt8
        public let a: Double
        
        public init(r: UInt8, g: UInt8, b: UInt8, a: Double) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
        
        public var description: String {
            guard a >= 0, a <= 1 else { return "rgba(\(r),\(g),\(b),\(1))" }
            return "rgba(\(r),\(g),\(b),\(a))"
        }
    }
}

// MARK: Default colors
extension CarbonStyle.Color {
    public static let all: [String: CarbonStyle.Color] = ["transparent": transparent,
                                                          "nef": nef,
                                                          "bow": bow,
                                                          "white": white,
                                                          "green": green,
                                                          "blue": blue,
                                                          "yellow": yellow,
                                                          "orange": orange]
    
    public static let nef = CarbonStyle.Color(r: 140, g: 68, b: 255, a: 1)
    public static let bow = CarbonStyle.Color(r: 213, g: 64, b: 72, a: 1)
    public static let transparent = CarbonStyle.Color(r: 255, g: 255, b: 255, a: 0)
    public static let white = CarbonStyle.Color(r: 255, g: 255, b: 255, a: 1)
    public static let yellow = CarbonStyle.Color(r: 255, g: 237, b: 117, a: 1)
    public static let green = CarbonStyle.Color(r: 110, g: 240, b: 167, a: 1)
    public static let blue = CarbonStyle.Color(r: 66, g: 197, b: 255, a: 1)
    public static let orange = CarbonStyle.Color(r: 255, g: 159, b: 70, a: 1)
}

// MARK: Error
public struct CarbonError: Error {
    public let filename: String
    public let snippet: String
    public let error: CarbonErrorOption
    
    public init(filename: String, snippet: String, error: CarbonErrorOption) {
        self.filename = filename
        self.snippet = snippet
        self.error = error
    }
    
    // MARK: Error options
    public enum CarbonErrorOption: CustomStringConvertible {
        case notFound
        case invalidSnapshot
        
        public var description: String {
            switch self {
            case .notFound: return "can not open carbon with selected code snippet"
            case .invalidSnapshot: return "can not take a snapshot"
            }
        }
    }
}

// MARK: - Constructors
extension CarbonStyle.Size {
    public init?(factor string: String) {
        guard let factor = Int8(string),
              let size = CarbonStyle.Size(rawValue: Double(factor)) else { return nil }
        self = size
    }
}

extension CarbonStyle.Color {
    public init?(hex: String) {
        let hexRaw = hex.hexColorWithAlpha
        guard hex.isHexColor else { return nil }
        guard let r = String(hexRaw.dropLast(6)).hexToUInt8,
              let g = String(hexRaw.dropFirst(2).dropLast(4)).hexToUInt8,
              let b = String(hexRaw.dropFirst(4).dropLast(2)).hexToUInt8,
              let a = String(hexRaw.dropFirst(6)).hexToUInt8 else { return nil }
        
        self = CarbonStyle.Color(r: r, g: g, b: b, a: min(Double(a)/255.0, 1.0))
    }
    
    public init?(default string: String) {
        guard let value = CarbonStyle.Color.all[string.lowercased()] else { return nil }
        self = value
    }
}

// MARK: Helpers
private extension String {
    var hexToUInt8: UInt8? {
        var result: CUnsignedInt = 666
        Scanner(string: self).scanHexInt32(&result)
        return result >= 0 && result <= 255 ? UInt8(result) : nil
    }
    
    var hexColorWithAlpha: String {
        let hex = lowercased().replacingOccurrences(of: "#", with: "")
        return hex.count < 8 ? "\(hex)ff" : hex
    }
    
    var isHexColor: Bool {
        let normalized = hexColorWithAlpha
        let hexSet = CharacterSet(charactersIn: "0123456789abcdef")
        let colorSet = CharacterSet(charactersIn: normalized)
        return colorSet.intersection(hexSet) == colorSet && normalized.count == 8
    }
}
