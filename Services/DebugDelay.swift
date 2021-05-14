//
//  DebugDelay.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import RedCat


enum DebugDelayKey : Dependency {
    static let defaultValue = DebugDelay.short
}


enum DebugDelay {
    case short
    case medium
    case long
    case stoneage
    var delayMs : ClosedRange<Int> {
        switch self {
        case .short:
            return 10...20
        case .medium:
            return 100...200
        case .long:
            return 400...800
        case .stoneage:
            return 5000...20000
        }
    }
}


extension Dependencies {
    var debugDelay : DebugDelay {
        get {
            self[DebugDelayKey.self]
        }
        set {
            self[DebugDelayKey.self] = newValue
        }
    }
}
