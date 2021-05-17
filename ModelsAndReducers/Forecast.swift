//
//  Forecast.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import RedCat


enum ResolvedForecast : Equatable {
    
    case hour(HourForecast)
    case day(DayForecast)
    case week(WeekForecast)
    
}

struct Forecast : Equatable {
    var city : String
    var rawForecastType : ForecastType
    var lastResult : ResolvedForecast?
    var requestState : Requestable<ForecastType, ResolvedForecast>
}

extension Forecast {
    
    static let reducer = ForecastReducer()
    
    typealias Actions = RedCat.Actions.Forecast
    
    struct ForecastReducer : ReducerWrapper {
        
        let body = forecastResponseReducer
            .compose(with: showCityReducer)
            .compose(with: showForecastReducer)
        
    }
    
    static let forecastResponseReducer = Reducer {
        (action: Actions.RespondWithForecast, state: inout Forecast) in
        guard state.city == action.city else {return}
        state.requestState.finalize(from: action.payload)
        if case .resolved(let response) = state.requestState {
            state.lastResult = response
        }
    }
    
    static let showCityReducer = Reducer {
        (action: Actions.ShowForecastForCity, state: inout Forecast) in
        state.city = action.newValue
        state.requestState = .requested(request: state.rawForecastType)
    }
    
    static let showForecastReducer = Reducer {
        (action: Actions.ShowForecastType, state: inout Forecast) in
        state.rawForecastType = action.newValue
        state.requestState = .requested(request: action.newValue)
    }
    
}

enum TemperatureUnit : String, Hashable {
    case celsius = "°C"
    case fahrenheit = "°F"
    case kelvin = "K"
}

struct HourForecast : Hashable {
    
    let hour : Int?
    let rainProbability : Double
    let temperature : Double 
    let temperatureUnit : TemperatureUnit
    
}


struct DayForecast : Hashable {
    
    let day : String
    let hourly : [HourForecast]
    
    var average : HourForecast {
        guard
            let first = hourly.first,
            hourly.lazy.map(\.temperatureUnit).allSatisfy({$0 == first.temperatureUnit}) else {
            fatalError()
        }
        return hourly.reduce(HourForecast(hour: nil,
                                          rainProbability: 0,
                                          temperature: 0,
                                          temperatureUnit: first.temperatureUnit)) {
            (aggregate, next) in
            HourForecast(hour: nil,
                         rainProbability: aggregate.rainProbability + (next.rainProbability) / Double(hourly.count),
                         temperature: aggregate.temperature + (next.temperature) / Double(hourly.count),
                         temperatureUnit: first.temperatureUnit)
        }
    }
    
}


struct WeekForecast : Hashable {
    
    let daily : [DayForecast]
    
}
