//
//  ForecastType.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.05.21.
//

import RedCat



enum ForecastType {
    
    case hour
    case day
    case week
    
    static let reducer = Reducer()
    
    struct Reducer : ReducerProtocol {
        
        typealias Action = Actions.ShowForecastType
        typealias State = ForecastType
        
        func apply(_ action: Actions.ShowForecastType,
                   to state: inout ForecastType) {
            state = action.newValue
        }
        
    }
    
}
