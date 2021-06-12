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
    
    struct CitiesReducer : ReducerProtocol {
        
        func apply(_ action: AppAction.PossibleCities,
                   to state: inout PossibleCities) {
            switch action {
            case .getPossibleCitiesCount(prefix: let prefix):
                getPossibleCitiesCount(prefix: prefix, in: &state)
            case .getPossibleCities(requestedIndex: let requestedIndex):
                getPossibleCities(requestedIndex: requestedIndex, in: &state)
            case .setPossibleCitiesCount(prefix: let prefix, count: let count):
                setPossibleCitiesCount(prefix: prefix, count: count, in: &state)
            case .setPossibleCities(prefix: let prefix, values: let values):
                setPossibleCities(prefix: prefix, values: values, in: &state)
            }
        }
        
        func getPossibleCitiesCount(prefix: String, in state: inout PossibleCities) {
            guard prefix != state.prefix else {
                state.requestState = .resolved(response: Cities(list: [.resolved(response: state.prefix)]))
                return
            }
            state.prefix = prefix
            state.requestState = .requested(request: prefix)
        }
        
        func getPossibleCities(requestedIndex: Int, in state: inout PossibleCities) {
            guard
                case .resolved(var cities) = state.requestState,
                cities.list.indices.contains(requestedIndex),
                case .empty = cities.list[requestedIndex] else {
                return
            }
            state.requestState = .empty
            cities.list[requestedIndex] = .requested(request: SingleCityRequest(index: requestedIndex,
                                                                                prefix: state.prefix))
            state.requestState = .resolved(response: cities)
        }
        
        func setPossibleCitiesCount(prefix: String, count: Result<Int, NSError>, in state: inout PossibleCities) {
            guard
                case .requested = state.requestState,
                prefix == state.prefix else {
                return
            }
            switch count {
            case .success(let count):
                state.requestState = .resolved(response: Cities(list: Array(repeating: .empty, count: count)))
            case .failure(let error):
                state.requestState = .failed(reason: error)
            }
        }
        
        func setPossibleCities(prefix: String,
                               values: [(index: Int, name: Result<String, NSError>)],
                               in state: inout PossibleCities) {
            guard
                state.prefix == prefix,
                case .resolved(var cities) = state.requestState else {
                return
            }
            state.requestState = .empty
            for (idx, name) in values {
                guard cities.list.indices.contains(idx) else {continue}
                cities.list[idx].finalize(from: name)
            }
            state.requestState = .resolved(response: cities)
            
        }
        
    }
    
    
}
