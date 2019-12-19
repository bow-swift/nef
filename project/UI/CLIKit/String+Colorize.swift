//  Copyright © 2019 The nef Authors.

import Foundation

/// Defined `styles`
extension String {
    public var bold: String { applyStyle(Colorize.bold) }
    public var dim: String { applyStyle(Colorize.dim) }
    public var italic: String { applyStyle(Colorize.italic) }
    public var underline: String { applyStyle(Colorize.underline) }
    public var blink: String { applyStyle(Colorize.blink) }
    public var reverse: String { applyStyle(Colorize.reverse) }
    public var hidden: String { applyStyle(Colorize.hidden) }
    public var strikethrough: String { applyStyle(Colorize.strikethrough) }
    public var reset: String { applyStyle(Colorize.reset) }
    
    fileprivate func applyStyle(_ codeStyle: ColorizeType) -> String {
        #if DEBUG
        return self
        #else
        guard codeStyle.open != Colorize.reset.open else { return Colorize.reset.open + self }
        let str = replacingOccurrences(of: Colorize.reset.open, with: Colorize.reset.open + codeStyle.open)
        return codeStyle.open + str + Colorize.reset.open
        #endif
    }
}

/// Defined `colors`
extension String {
    public var black: String { applyStyle(Colorize.black) }
    public var red: String { applyStyle(Colorize.red) }
    public var green: String { applyStyle(Colorize.green) }
    public var yellow: String { applyStyle(Colorize.yellow) }
    public var blue: String { applyStyle(Colorize.blue) }
    public var magenta: String { applyStyle(Colorize.magenta) }
    public var cyan: String { applyStyle(Colorize.cyan) }
    public var lightGray: String { applyStyle(Colorize.lightGray) }
    public var darkGray: String { applyStyle(Colorize.darkGray) }
    public var lightRed: String { applyStyle(Colorize.lightRed) }
    public var lightGreen: String { applyStyle(Colorize.lightGreen) }
    public var lightYellow: String { applyStyle(Colorize.lightYellow) }
    public var lightBlue: String { applyStyle(Colorize.lightBlue) }
    public var lightMagenta: String { applyStyle(Colorize.lightMagenta) }
    public var lightCyan: String { applyStyle(Colorize.lightCyan) }
    public var white: String { applyStyle(Colorize.white) }
    
    public var onBlack: String { applyStyle(Colorize.onBlack) }
    public var onRed: String { applyStyle(Colorize.onRed) }
    public var onGreen: String { applyStyle(Colorize.onGreen) }
    public var onYellow: String { applyStyle(Colorize.onYellow) }
    public var onBlue: String { applyStyle(Colorize.onBlue) }
    public var onMagenta: String { applyStyle(Colorize.onMagenta) }
    public var onCyan: String { applyStyle(Colorize.onCyan) }
    public var onLightGray: String { applyStyle(Colorize.onLightGray) }
    public var onDarkGray: String { applyStyle(Colorize.onDarkGray) }
    public var onLightRed: String { applyStyle(Colorize.onLightRed) }
    public var onLightGreen: String { applyStyle(Colorize.onLightGreen) }
    public var onLightYellow: String { applyStyle(Colorize.onLightYellow) }
    public var onLightBlue: String { applyStyle(Colorize.onLightBlue) }
    public var onLightMagenta: String { applyStyle(Colorize.onLightMagenta) }
    public var onLightCyan: String { applyStyle(Colorize.onLightCyan) }
    public var onWhite: String { applyStyle(Colorize.onWhite) }
}


// MARK: - Colors and Styles definition

typealias ColorizeType = (open: String, close: String)

// https://github.com/mtynior/ColorizeSwift
enum Colorize {
    static let bold: ColorizeType            = ("\u{001B}[1m", "\u{001B}[22m")
    static let dim: ColorizeType             = ("\u{001B}[2m", "\u{001B}[22m")
    static let italic: ColorizeType          = ("\u{001B}[3m", "\u{001B}[23m")
    static let underline: ColorizeType       = ("\u{001B}[4m", "\u{001B}[24m")
    static let blink: ColorizeType           = ("\u{001B}[5m", "\u{001B}[25m")
    static let reverse: ColorizeType         = ("\u{001B}[7m", "\u{001B}[27m")
    static let hidden: ColorizeType          = ("\u{001B}[8m", "\u{001B}[28m")
    static let strikethrough: ColorizeType   = ("\u{001B}[9m", "\u{001B}[29m")
    static let reset: ColorizeType           = ("\u{001B}[0m", "")
   
    static let black: ColorizeType           = ("\u{001B}[30m", "\u{001B}[0m")
    static let red: ColorizeType             = ("\u{001B}[31m", "\u{001B}[0m")
    static let green: ColorizeType           = ("\u{001B}[32m", "\u{001B}[0m")
    static let yellow: ColorizeType          = ("\u{001B}[33m", "\u{001B}[0m")
    static let blue: ColorizeType            = ("\u{001B}[34m", "\u{001B}[0m")
    static let magenta: ColorizeType         = ("\u{001B}[35m", "\u{001B}[0m")
    static let cyan: ColorizeType            = ("\u{001B}[36m", "\u{001B}[0m")
    static let lightGray: ColorizeType       = ("\u{001B}[37m", "\u{001B}[0m")
    static let darkGray: ColorizeType        = ("\u{001B}[90m", "\u{001B}[0m")
    static let lightRed: ColorizeType        = ("\u{001B}[91m", "\u{001B}[0m")
    static let lightGreen: ColorizeType      = ("\u{001B}[92m", "\u{001B}[0m")
    static let lightYellow: ColorizeType     = ("\u{001B}[93m", "\u{001B}[0m")
    static let lightBlue: ColorizeType       = ("\u{001B}[94m", "\u{001B}[0m")
    static let lightMagenta: ColorizeType    = ("\u{001B}[95m", "\u{001B}[0m")
    static let lightCyan: ColorizeType       = ("\u{001B}[96m", "\u{001B}[0m")
    static let white: ColorizeType           = ("\u{001B}[97m", "\u{001B}[0m")
    
    static let onBlack: ColorizeType         = ("\u{001B}[40m", "\u{001B}[0m")
    static let onRed: ColorizeType           = ("\u{001B}[41m", "\u{001B}[0m")
    static let onGreen: ColorizeType         = ("\u{001B}[42m", "\u{001B}[0m")
    static let onYellow: ColorizeType        = ("\u{001B}[43m", "\u{001B}[0m")
    static let onBlue: ColorizeType          = ("\u{001B}[44m", "\u{001B}[0m")
    static let onMagenta: ColorizeType       = ("\u{001B}[45m", "\u{001B}[0m")
    static let onCyan: ColorizeType          = ("\u{001B}[46m", "\u{001B}[0m")
    static let onLightGray: ColorizeType     = ("\u{001B}[47m", "\u{001B}[0m")
    static let onDarkGray: ColorizeType      = ("\u{001B}[100m", "\u{001B}[0m")
    static let onLightRed: ColorizeType      = ("\u{001B}[101m", "\u{001B}[0m")
    static let onLightGreen: ColorizeType    = ("\u{001B}[102m", "\u{001B}[0m")
    static let onLightYellow: ColorizeType   = ("\u{001B}[103m", "\u{001B}[0m")
    static let onLightBlue: ColorizeType     = ("\u{001B}[104m", "\u{001B}[0m")
    static let onLightMagenta: ColorizeType  = ("\u{001B}[105m", "\u{001B}[0m")
    static let onLightCyan: ColorizeType     = ("\u{001B}[106m", "\u{001B}[0m")
    static let onWhite: ColorizeType         = ("\u{001B}[107m", "\u{001B}[0m")
    
    static let required: ColorizeType = lightCyan
    static let optional: ColorizeType = lightMagenta
}
