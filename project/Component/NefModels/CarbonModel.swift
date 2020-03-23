//  Copyright © 2019 The nef Authors.

import Foundation

/// Represents the configuration for rendering carbon snippets.
public struct CarbonModel: Codable, Equatable {
    /// Code to render as a Carbon image.
    public let code: String
    
    /// Style to apply to the generated snippet.
    public let style: CarbonStyle
    
    /// Initializes a `CarbonModel`
    ///
    /// - Parameters:
    ///   - code: code to render as a Carbon image.
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
    
    /// Image size.
    public let size: Size
    
    /// Carbon theme.
    public let theme: Theme
    
    /// Carbon font type.
    public let fontType: Font
    
    /// Shows/hides lines of code.
    public let lineNumbers: Bool
    
    /// Shows/hides nef watermark.
    public let watermark: Bool
    
    /// Initializes a `CarbonStyle`
    ///
    /// - Parameters:
    ///   - background: background color.
    ///   - theme: carbon theme.
    ///   - size: exported image size.
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
    
    /// Represents image size.
    public enum Size: Double, Codable, Equatable, CaseIterable {
        /// Output image size to 1x
        case x1 = 1
        /// Output image size to 2x
        case x2 = 2
        /// Output image size to 3x
        case x3 = 3
        /// Output image size to 4x
        case x4 = 4
        /// Output image size to 5x
        case x5 = 5
    }
    
    /// Represents a Carbon theme.
    public enum Theme: String, Codable, Equatable, CaseIterable {
        /// Base 16 dark
        case base16 = "base16-dark"
        
        /// Blackboard
        case blackboard
        
        /// Cobalt
        case cobalt
        
        /// Duotone dark
        case duotone = "duotone-dark"
        
        /// Dracula
        case dracula
        
        /// Hopscotch
        case hopscotch
        
        /// Lucario
        case lucario
        
        /// Material
        case material
        
        ///Monokai
        case monokai
        
        /// Night Owl
        case nightOwl = "night-owl"
        
        /// Nord
        case nord
        
        /// Oceanic Next
        case oceanicNext = "oceanic-next"
        
        /// One Dark
        case oneDark = "one-dark"
        
        /// Panda
        case panda = "panda-syntax"
        
        /// Paraiso dark
        case paraiso = "paraiso-dark"
        
        /// Shades of purple
        case purple = "shades-of-purple"
        
        /// Seti
        case seti
        
        /// Solarized dark
        case solarized = "solarized dark"
        
        /// Synthwave 84
        case synthwave84 = "synthwave-84"
        
        /// Tomorrow night bright
        case tomorrow = "tomorrow-night-bright"
        
        /// Twilight
        case twilight
        
        /// Verminal
        case verminal
        
        /// VSCode
        case vscode
        
        /// Zenburn
        case zenburn
    }
    
    /// Represents a Carbon font type
    public enum Font: String, Codable, Equatable, CaseIterable {
        /// Fira Code
        case firaCode = "Fira Code"
        
        /// Hack
        case hack = "Hack"
        
        /// Inconsolata
        case inconsolata = "Inconsolata"
        
        /// Iosevka
        case iosevka = "Iosevka"
        
        /// Monoid
        case monoid = "Monoid"
        
        /// Anonymous Pro
        case anonymous = "Anonymous Pro"
        
        /// Source Code Pro
        case sourceCodePro = "Source Code Pro"
        
        /// Dark Mono
        case darkMono = "dm"
        
        /// Droid Sans Mono
        case droidMono = "Droid Sans Mono"
        
        /// Fantasque Sans Mono
        case fantasqueMono = "Fantasque Sans Mono"
        
        /// IBM Plex Mono
        case ibmPlexMono = "IBM Plex Mono"
        
        /// Space Mono
        case spaceMono = "Space Mono"
        
        /// Ubuntu Mono
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
        
        /// Initializes a `CarbonStyle.Color`
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

extension CarbonStyle: CustomStringConvertible {
    
    /// A textual representation of `CarbonStyle`.
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
    
    /// Snippet that was being rendered when the action failed.
    public let snippet: String
    
    /// Describes the reason for the failure.
    public let cause: CarbonError.Cause
    
    /// Initializes a `CarbonError`
    ///
    /// - Parameters:
    ///   - snippet: snippet of code that was being rendered when the action failed.
    ///   - cause: reason for the failure.
    public init(snippet: String, cause: CarbonError.Cause) {
        self.snippet = snippet
        self.cause = cause
    }
    
    /// Models the reason of a carbon error.
    public enum Cause: Error, CustomStringConvertible {
        ///  Could not open Carbon web view with the current configuration.
        case notFound
        
        /// Could not take a snapshot.
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
    
    /// Initializes a `CarbonStyle.Size`
    ///
    /// - Parameter factor: export image size.
    public init?(factor string: String) {
        guard let factor = Int8(string),
              let size = CarbonStyle.Size(rawValue: Double(factor)) else { return nil }
        self = size
    }
}

extension CarbonStyle.Color {
    
    /// Initializes a `CarbonStyle.Color`
    ///
    /// - Parameter hex: creates a `Color` from a hexadecimal String.
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

// MARK: - private <helpers>
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
