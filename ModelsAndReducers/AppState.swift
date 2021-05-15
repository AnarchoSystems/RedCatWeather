//
//  AppState.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import Foundation
import RedCat
import CasePaths
import SwiftUI

struct Identified<ID : Hashable, T> : Identifiable {
    var value : T
    let id : ID// swiftlint:disable:this identifier_name
}

extension Identified where ID == UUID {
    init(value: T) {
        self.value = value
        self.id = UUID()
    }
}

public struct AppState {
    
    var error : Identified<UUID, NSError>?
    var currentForecast : Forecast
    var possibleCities : PossibleCities
    var currentMenu : Menu
    var hasShownSlowInternetError = false
    
    enum Menu {
        case forecast
        case cities
    }
    
    var defaultCity : String {
        get {
            UserDefaults.standard.string(forKey: "DefaultCity") ?? "Berlin"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "DefaultCity")
        }
    }
    
    static let reducer = AppReducer()
    
    struct AppReducer : ReducerWrapper {
        
        let body = initReducer
            .compose(with: Forecast.reducer, property: \.currentForecast)
            .compose(with: PossibleCities.reducer, property: \.possibleCities)
            .compose(with: goToCitiesMenuReducer)
            .compose(with: dismissCityRequestOnShowCity)
            .compose(with: errorReducer)
            .compose(with: deinitReducer)
        
    }
    
    static let goToCitiesMenuReducer = Reducer {
        (_: Actions.GetPossibleCitiesCount, state: inout AppState) in
        state.currentMenu = .cities
    }
    
    static let dismissCityRequestOnShowCity = Reducer {
        (_: Actions.ShowForecastForCity, state: inout AppState) in
        state.currentMenu = .forecast
    }
    
    static let initReducer = Reducer {
        (_: AppInit, state: inout AppState) in
        state.currentForecast.city = state.defaultCity
        state.currentForecast.requestState = .requested(request: state.currentForecast.rawForecastType)
    }
    
    static let errorReducer = ErrorReducer()
    
    static let deinitReducer = Reducer {
        (_: AppDeinit, state: inout AppState) in
        state.defaultCity = state.currentForecast.city
    }
    
    // only a class so I can use lazy
    // if body was a computed property, the type would get ugly
    class ErrorReducer : ReducerWrapper {
        
        lazy var body = setError
            .compose(with: dismiss, property: \.error)
        
        let setError = Reducer {
            (action: Actions.SetError, state: inout AppState, environment) in
            guard state.error == nil else {return}
            if action.error.localizedRecoverySuggestion == environment.slowInternetWarning.hint {
                if !state.hasShownSlowInternetError {
                    state.error = Identified(value: action.error)
                }
                state.hasShownSlowInternetError = true
            }
            else {
                state.error = Identified(value: action.error)
            }
        }
        
        let dismiss = Reducer {
            (_: Actions.DismissError, state: inout Identified<UUID, NSError>?) in
            state = nil
        }
        
    }
    
}
