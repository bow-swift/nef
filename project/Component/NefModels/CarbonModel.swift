//  Copyright © 2019 The nef Authors.

import Foundation

/// Represents the configuration for the rendering of carbon snippets.
public struct CarbonModel: Codable, Equatable {
    /// Code to render into Carbon image.
    public let code: String
    
    /// Style to apply to the generated snippet.
    public let style: CarbonStyle
    
    /// Initializes a `CarbonModel`.
    ///
    /// - Parameters:
    ///   - code: code to render into Carbon image.
    ///   - style: style to apply to the generated snippet.
    public init(code: String, style: CarbonStyle) {
        self.code = code
        self.style = style
    }
}

/// Describes the style to apply to Carbon snippet.
public struct CarbonStyle: Codable, Equatable {
    /// Background color
    public let background: Color
    
    /// File size.
    public let size: Size
    
    /// Carbon theme.
    public let theme: Theme
    
    /// Carbon font type.
    public let fontType: Font
    
    /// Shows/hides lines of code.
    public let lineNumbers: Bool
    
    /// Shows/hides nef watermark.
    public let watermark: Bool
    
    /// Initializes a `CarbonStyle`.
    ///
    /// - Parameters:
    ///   - background: background color in hexadecimal.
    ///   - theme: carbon theme.
    ///   - size: export file size.
    ///   - fontType: carbon font type.
    ///   - lineNumbers: shows/hides lines of code.
    ///   - watermark: shows/hides the watermark.
    public init(background: Color, theme: Theme, size: Size, fontType: Font, lineNumbers: Bool, watermark: Bool) {
        self.background = background
        self.theme = theme
        self.size = size
        self.fontType = fontType
        self.lineNumbers = lineNumbers
        self.watermark = watermark
    }
    
    /// Represents file size.
    public enum Size: Double, Codable, Equatable, CaseIterable {
        case x1 = 1
        case x2 = 2
        case x3 = 3
        case x4 = 4
        case x5 = 5
    }
    
    /// Represents Carbon theme.
    public enum Theme: String, Codable, Equatable, CaseIterable {
        case base16 = "base16-dark"
        case blackboard
        case cobalt
        case duotone = "duotone-dark"
        case dracula
        case hopscotch
        case lucario
        case material
        case monokai
        case nightOwl = "night-owl"
        case nord
        case oceanicNext = "oceanic-next"
        case oneDark = "one-dark"
        case panda = "panda-syntax"
        case paraiso = "paraiso-dark"
        case purple = "shades-of-purple"
        case seti
        case solarized = "solarized dark"
        case synthwave84 = "synthwave-84"
        case tomorrow = "tomorrow-night-bright"
        case twilight
        case verminal
        case vscode
        case zenburn
    }
    
    /// Represents Carbon font type
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
    
    /// Represents background color
    public struct Color: CustomStringConvertible, Codable, Equatable {
        /// The red value of the color object. Values between [0, 255]
        public let r: UInt8
        
        /// The green value of the color object. Values between [0, 255]
        public let g: UInt8
        
        /// The blue value of the color object. Values between [0, 255]
        public let b: UInt8
        
        /// The alpha value of the color object. Values between [0.0, 1.0]
        public let a: Double
        
        /// Initializes a `CarbonStyle.Color`.
        ///
        /// - Parameters:
        ///   - r: the red value of the color object.
        ///   - g: the green value of the color object.
        ///   - b: the blue value of the color object.
        ///   - a: the alpha value of the color object.
        public init(r: UInt8, g: UInt8, b: UInt8, a: Double) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
        
        /// A query string representation of `Color`.
        public var description: String {
            guard a >= 0, a <= 1 else { return "rgba(\(r),\(g),\(b),\(1))" }
            return "rgba(\(r),\(g),\(b),\(a))"
        }
    }
}

/// A textual representation of `CarbonStyle`.
extension CarbonStyle: CustomStringConvertible {
    public var description: String {
        """
                background: \(background)
                size: \(size)
                theme: \(theme.rawValue)
                fontType: \(fontType.rawValue)
                lineNumbers: \(lineNumbers)
                watermark: \(watermark)
        """
    }
}

/// Predefined Carbon `Color`.
extension CarbonStyle.Color {
    
    /// A group of predefined Carbon colours.
    public static let all: [String: CarbonStyle.Color] = ["nef": nef,
                                                          "bow": bow,
                                                          "white": white,
                                                          "green": green,
                                                          "blue": blue,
                                                          "yellow": yellow,
                                                          "orange": orange]
    
    /// Predefined nef `Color`.
    public static let nef = CarbonStyle.Color(r: 140, g: 68, b: 255, a: 1)
    
    /// Predefined bow `Color`.
    public static let bow = CarbonStyle.Color(r: 213, g: 64, b: 72, a: 1)
    
    /// Predefined white `Color`.
    public static let white = CarbonStyle.Color(r: 255, g: 255, b: 255, a: 1)
    
    /// Predefined yellow `Color`.
    public static let yellow = CarbonStyle.Color(r: 255, g: 237, b: 117, a: 1)
    
    /// Predefined green `Color`.
    public static let green = CarbonStyle.Color(r: 110, g: 240, b: 167, a: 1)
    
    /// Predefined blue `Color`.
    public static let blue = CarbonStyle.Color(r: 66, g: 197, b: 255, a: 1)
    
    /// Predefined orange `Color`.
    public static let orange = CarbonStyle.Color(r: 255, g: 159, b: 70, a: 1)
}

/// Represents an error in a Carbon action.
public struct CarbonError: Error {
    
    /// The snippet of code fails in the action.
    public let snippet: String
    
    /// Describe the reason for the failure.
    public let cause: CarbonError.Cause
    
    /// Initializes a `CarbonError`.
    ///
    /// - Parameters:
    ///   - snippet: the snippet of code fails in the action
    ///   - cause: the reason for the failure.
    public init(snippet: String, cause: CarbonError.Cause) {
        self.snippet = snippet
        self.cause = cause
    }
    
    /// Models the reason of a carbon error.
    ///
    /// - notFound: Could not open Carbon web view with the current configuration.
    /// - invalidSnapshot: Could not take a snapshot.
    public enum Cause: Error, CustomStringConvertible {
        case notFound
        case invalidSnapshot
        
        /// A textual representation of `CarbonError.Cause`.
        public var description: String {
            switch self {
            case .notFound: return "can not open carbon with selected code snippet"
            case .invalidSnapshot: return "can not take a snapshot"
            }
        }
    }
}

extension CarbonStyle.Size {
    
    /// Initializes a `CarbonStyle.Size`.
    ///
    /// - Parameters:
    ///   - factor: export file size.
    public init?(factor string: String) {
        guard let factor = Int8(string),
              let size = CarbonStyle.Size(rawValue: Double(factor)) else { return nil }
        self = size
    }
}

extension CarbonStyle.Color {
    
    /// Initializes a `CarbonStyle.Color`.
    ///
    /// - Parameter hex: creates a `Color` from an hexadecimal.
    public init?(hex: String) {
        let hexRaw = hex.hexColorWithAlpha
        guard hex.isHexColor else { return nil }
        guard let r = String(hexRaw.dropLast(6)).hexToUInt8,
              let g = String(hexRaw.dropFirst(2).dropLast(4)).hexToUInt8,
              let b = String(hexRaw.dropFirst(4).dropLast(2)).hexToUInt8,
              let a = String(hexRaw.dropFirst(6)).hexToUInt8 else { return nil }
        
        self = CarbonStyle.Color(r: r, g: g, b: b, a: min(Double(a)/255.0, 1.0))
    }
    
    /// Initializes a `CarbonStyle.Color`.
    ///
    /// - Parameter default: creates a `Color` from a predefined value.
    public init?(default string: String) {
        guard let value = CarbonStyle.Color.all[string.lowercased()] else { return nil }
        self = value
    }
    
    /// Converts `Color` into its hexadecimal representation.
    public var hex: String {
        let opacity = UInt8(255 * a)
        return "\(r.hex)\(g.hex)\(b.hex)\(opacity.hex)"
    }
}

// MARK: - Helpers
private extension UInt8 {
    var hex: String { String(format: "%02X", self) }
}

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
