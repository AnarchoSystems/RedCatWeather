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
    
    struct AppReducer : DispatchReducerProtocol {
        
        func dispatch(_ action: AppAction) -> VoidReducer<AppState> {
            
            switch action {
            
            case .appInit:
                return initReducer.asVoidReducer()
                
            case .forecast(let action):
                return Forecast.reducer.bind(to: \.currentForecast).send(action)
                
            case .error(let action):
                return errorReducer.send(action)
                
            case .possibleCities(let action):
                return goToCitiesMenuReducer.send(action)
                    .compose(with: PossibleCities.reducer.bind(to: \.possibleCities).send(action))
                    .asVoidReducer()
                
            case .showForecastScreen:
                return dismissCityRequestOnShowCity.asVoidReducer()
                
            case .shutdown:
                return deinitReducer.asVoidReducer()
                
            }
            
        }
        
    }
    
    static let goToCitiesMenuReducer = Reducer {
        (_: AppAction.PossibleCities, state: inout AppState) in
        state.currentMenu = .cities
    }
    
    static let dismissCityRequestOnShowCity = Reducer {
        (_: Void, state: inout AppState) in
        state.currentMenu = .forecast
    }
    
    static let initReducer = Reducer {
        (_: Void, state: inout AppState) in
        state.currentForecast.city = state.defaultCity
        state.currentForecast.requestState = .requested(request: state.currentForecast.rawForecastType)
    }
    
    static let errorReducer = ErrorReducer()
    
    static let deinitReducer = Reducer {
        (_: Void, state: inout AppState) in
        state.defaultCity = state.currentForecast.city
    }
    
    // only a class so I can use lazy
    // if body was a computed property, the type would get ugly
    struct ErrorReducer : ReducerProtocol {
        
        
        func apply(_ action: AppAction.Error,
                   to state: inout AppState) {
            switch action {
            case .setError(error: let error, isSlowInternetError: let isSlowInternetError):
                setError(error: error, isSlowInternetError: isSlowInternetError, in: &state)
            case .dismissError:
                dismissError(in: &state)
            }
        }
        
        func setError(error: NSError, isSlowInternetError: Bool, in state: inout AppState) {
            guard state.error == nil else {return}
            if isSlowInternetError {
                if !state.hasShownSlowInternetError {
                    state.error = Identified(value: error)
                }
                state.hasShownSlowInternetError = true
            }
            else {
                state.error = Identified(value: error)
            }
        }
        
        func dismissError(in state: inout AppState) {
            state.error = nil
        }
        
    }
    
}
