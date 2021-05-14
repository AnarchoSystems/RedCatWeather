//
//  PossibleCities.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import Foundation
import RedCat
import CasePaths



extension Identified : Equatable where T : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}

struct SingleCityRequest : Hashable {
    let index : Int
    let prefix : String
}

typealias RequestableCity = Requestable<SingleCityRequest, String>

struct Cities : Equatable {
    var list : [RequestableCity]
}

typealias RequestableCityList = Requestable<String, Cities>

struct PossibleCities : Equatable {
    
    var prefix : String
    var requestState : RequestableCityList
    
    var values : [RequestableCity] {
        if case .resolved(let response) = requestState {
            return response.list
        }
        return []
    }
    
    static let reducer = CitiesReducer()
    
    struct CitiesReducer : ReducerWrapper {
        
        let body = prefixReducer
            .compose(with: maxCountReducer)
            .compose(with: valuesRequestReducer)
            .compose(with: valuesResponseReducer)
        
    }
    
    static let prefixReducer = Reducer {
        (action: Actions.GetPossibleCitiesCount, state: inout PossibleCities) in
        guard action.prefix != state.prefix else {
            state.requestState = .resolved(response: Cities(list: [.resolved(response: state.prefix)]))
            return
        }
        state.prefix = action.prefix
        state.requestState = .requested(request: action.prefix)
    }
    
    static let maxCountReducer = Reducer {
        (action: Actions.SetPossibleCitiesCount, state: inout PossibleCities) in
        guard
            case .requested = state.requestState,
            action.prefix == state.prefix else {
            return
        }
        switch action.count {
        case .success(let count):
            state.requestState = .resolved(response: Cities(list: Array(repeating: .empty, count: count)))
        case .failure(let error):
            state.requestState = .failed(reason: error)
        }
    }
    
    static let valuesRequestReducer = Reducer {
        (action: Actions.GetPossibleCities, state: inout PossibleCities) in
        guard
            case .resolved(var cities) = state.requestState,
            cities.list.indices.contains(action.requestedIndex),
            case .empty = cities.list[action.requestedIndex] else {
            return
        }
        state.requestState = .empty
        cities.list[action.requestedIndex] = .requested(request: SingleCityRequest(index: action.requestedIndex,
                                                                                   prefix: state.prefix))
        state.requestState = .resolved(response: cities)
    }
    
    static let valuesResponseReducer = Reducer {
        (action: Actions.SetPossibleCities, state: inout PossibleCities) in
        guard
            state.prefix == action.prefix,
            case .resolved(var cities) = state.requestState else {
            return
        }
        state.requestState = .empty
        for (idx, name) in action.values {
            guard cities.list.indices.contains(idx) else {continue}
            cities.list[idx].finalize(from: name)
        }
        state.requestState = .resolved(response: cities)
    }
    
}
