//
//  Actions.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.05.21.
//

import Foundation
import RedCat


enum AppAction : SequentiallyComposable {
    
    case appInit
    case forecast(action: Forecast)
    case error(action: Error)
    case possibleCities(action: PossibleCities)
    case showForecastScreen
    case shutdown
    
    static func showForecastForCity(oldValue: String, newValue: String) -> ActionGroup<Self> {
        AppAction.forecast(action: .showForecastForCity(oldValue: oldValue, newValue: newValue))
            .then(showForecastScreen)
    }
    
}

extension AppAction {
    
    enum PossibleCities {
        
        case getPossibleCitiesCount(prefix: String)
        case getPossibleCities(requestedIndex: Int)
        case setPossibleCitiesCount(prefix: String, count: Result<Int, NSError>)
        case setPossibleCities(prefix: String, values: [(index: Int, name: Result<String, NSError>)])
        
    }
    
    enum Error {
        
        case setError(error: NSError, isSlowInternetError: Bool)
        case dismissError
        
    }
    
    enum Forecast {
        
        case showForecastForCity(oldValue: String, newValue: String)
        case showForecastType(oldValue: ForecastType, newValue: ForecastType)
        case respondWithForecast(city: String, payload: Result<ResolvedForecast, NSError>)
        
    }

}
