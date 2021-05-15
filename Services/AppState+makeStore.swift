//
//  AppState+makeStore.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 15.05.21.
//

import RedCat



extension AppState {
    
    static func makeStore(configure: (Dependencies) -> AppState = configureDefaultState) -> CombineStore<AppState> {
        Store.combineStore(reducer: reducer,
                           environment: dependencies,
                           services: [CityRequestService(detail: \.possibleCities),
                                      ForecastRequestService(detail: \.currentForecast)],
                           configure: configure)
    }
    
    // for previews / debug
    static func makeStore(configure: (inout AppState) -> Void) -> CombineStore<AppState> {
        makeStore {(env : Dependencies) in
            var state = configureDefaultState(env)
            configure(&state)
            return state
        }
    }
    
    // for previews / debug
    static func configureDefaultState(_ env: Dependencies) -> AppState {
        AppState(error: nil,
                 currentForecast: Forecast(city: "",
                                           rawForecastType: .day,
                                           requestState: .empty),
                 possibleCities: PossibleCities(prefix: "",
                                                requestState: .empty),
                 currentMenu: .forecast)
    }
    
    
    static let dependencies = Dependencies {
        Bind(\.debugDelay, to: .stoneage)
    }
    
}
