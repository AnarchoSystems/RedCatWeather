//
//  WeatherColor.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import SwiftUI


extension RainRange {
    
    var color : Color {
        switch self {
        case .sunny:
            return Color(UIColor.systemBlue)
        case .clouds, .maybeRain:
            return Color(UIColor.systemTeal)
        case .rain:
            return Color(UIColor.systemGray2)
        case .stayAtHome:
            return Color(UIColor.systemGray)
        }
    }
    
}
