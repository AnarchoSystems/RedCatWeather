//
//  RainRange.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//


enum RainRange : Character {
    case sunny = "☀️" 
    case clouds = "⛅️"
    case maybeRain = "🌦"
    case rain = "🌧"
    case stayAtHome = "⛈"
    init(rainProbability: Double) {
        switch Int(100 * rainProbability) {
        case 0...10:
            self = .sunny
        case 10...40:
            self = .clouds
        case 40...60:
            self = .maybeRain
        case 60...85:
            self = .rain
        default:
            self = .stayAtHome
        }
    }
}

extension HourForecast {
    var rainRange : RainRange {
        RainRange(rainProbability: rainProbability)
    }
}

extension DayForecast {
    var rainRange : RainRange {
        RainRange(rainProbability: average.rainProbability)
    }
}

extension WeekForecast {
    var rainRange : RainRange {
        RainRange(rainProbability: DayForecast(day: "?",
                                               hourly: daily.map(\.average)).average.rainProbability)
    }
}

extension ResolvedForecast {
    
    var rainRange : RainRange {
        
        switch self {
        
        case .hour(let hour):
            return hour.rainRange
            
        case .day(let day):
            return day.rainRange
            
        case .week(let week):
            return week.rainRange
        }
        
    }
    
}
