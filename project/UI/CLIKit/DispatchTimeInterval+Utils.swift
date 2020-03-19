//  Copyright © 2019 The nef Authors.

import Foundation

extension DispatchTimeInterval {
    var double: Double? {
        switch self {
        case .seconds(let value): return Double(value)
        case .milliseconds(let value): return Double(value) * 0.001
        case .microseconds(let value): return Double(value) * 0.000_001
        case .nanoseconds(let value): return Double(value) * 0.000_000_001
        case .never: return nil
        @unknown default: return nil
        }
    }
}

extension DispatchTimeInterval: Comparable {
    public static func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
        let now = DispatchTime.now()
        return (now + lhs) < (now + rhs)
    }
}

func -(lhs: DispatchTime, rhs: DispatchTime) -> DispatchTimeInterval {
    let l = Int(lhs.rawValue)
    let r = Int(rhs.rawValue)
    return .nanoseconds(Int(l - r))
}
