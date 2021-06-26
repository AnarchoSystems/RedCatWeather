//
//  Forecast.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import Foundation
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
    
    struct ForecastReducer : ReducerProtocol {
        
        func apply(_ action: AppAction.Forecast,
                   to state: inout Forecast) {
            
            switch action {
            case .showForecastType(oldValue: _, newValue: let newValue):
                showForecastType(newValue: newValue, in: &state)
                
            case .respondWithForecast(city: let city, payload: let payload):
                respondWithForecast(city: city, payload: payload, in: &state)
                
            case .showForecastForCity(oldValue: _, newValue: let newValue):
                showForecastForCity(newValue: newValue, in: &state)
                
            }
            
        }
        
        func respondWithForecast(city: String, payload: Result<ResolvedForecast, NSError>, in state: inout Forecast) {
            
            state.requestState.finalize(from: payload)
            
            if case .resolved(let response) = state.requestState {
                state.lastResult = response
            }
            
        }
        
        func showForecastType(newValue: ForecastType, in state: inout Forecast) {
            
            state.rawForecastType = newValue
            state.requestState = .requested(request: newValue)
            
        }
        
        func showForecastForCity(newValue: String, in state: inout Forecast) {
            
            state.city = newValue
            state.requestState = .requested(request: state.rawForecastType)
            
        }
        
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
            fatalError("Conversion not implemented")
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
