//
//  Actions.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.05.21.
//

import Foundation
import RedCat


enum Actions {
    
    struct ShowForecastForCity : Change {
        var oldValue : String
        var newValue : String
    }
    
    struct ShowForecastType : Change {
        var oldValue : ForecastType
        var newValue : ForecastType
    }
    
    struct GetPossibleCitiesCount : ActionProtocol, Equatable {
        let prefix : String
    }
    
    struct GetPossibleCities : ActionProtocol, Equatable {
        let requestedIndex : Int
    }
    
    struct SetPossibleCitiesCount : ActionProtocol {
        let prefix : String 
        let count : Result<Int, NSError>
    }
    
    struct SetPossibleCities : ActionProtocol {
        let prefix : String
        let values : [(index: Int, name: Result<String, NSError>)]
    }
    
    struct RespondWithForecast : ActionProtocol {
        let city : String
        let payload : Result<ResolvedForecast, NSError>
    }
    
    struct SetError : ActionProtocol {
        let error : NSError
    }
    
    struct DismissError : ActionProtocol {}
    
}
