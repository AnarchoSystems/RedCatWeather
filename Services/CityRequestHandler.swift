//
//  CityRequestHandler.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import Foundation
import RedCat


enum CityRequestHandler : Config {
    static func value(given: Dependencies) -> CityRequestResolver {
        if given.nativeValues.debug {
            return MockCityResolver(delay: given.debugDelay).cached()
        }
        else {
            fatalError("Not implemented")
        }
    }
}

extension Dependencies {
    
    var cityRequestHandler : CityRequestResolver {
        get {
            self[CityRequestHandler.self]
        }
        set {
            self[CityRequestHandler.self] = newValue
        }
    }
    
}


class CityRequestService : DetailService<AppState, PossibleCities, AppAction> {
    
    @Injected(\.cityRequestHandler) var requestHandler
    @Injected(\.slowInternetWarning) var slowInternetWarning
    
    func extractDetail(from state: AppState) -> PossibleCities {
        state.possibleCities
    }
    
    func onUpdate(newValue: PossibleCities) {
        
        var answered = false
        
        switch newValue.requestState {
        
        case .empty, .failed:
            return
            
        case .requested(let request):
            requestCityCount(prefix: request,
                             handler: requestHandler,
                             then: {answered = true})
            
        case .resolved(let list):
            let requests = requestsToMake(oldList: oldValue.values,
                                          newList: list.list)
            
            requestCities(requests,
                          prefix: newValue.prefix,
                          handler: requestHandler,
                          then: {answered = true})
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            guard !answered else {return}
            self.store.send(.error(action: .setError(error: self.slowInternetWarning.makeNSError(),
                                                 isSlowInternetError: true)))
        }
        
    }
    
    private func requestCities(_ indices: [Int],
                               prefix: String,
                               handler: CityRequestResolver,
                               then: @escaping () -> Void) {
        
        handler.getPossibleCities(withPrefix: prefix, indices: indices) {response in
            DispatchQueue.main.async {
                self.store.send(.possibleCities(action: .setPossibleCities(prefix: prefix,
                                                                     values: Array(zip(indices, response)))))
                then()
            }
        }
        
    }
    
    private func requestCityCount(prefix: String,
                                  handler: CityRequestResolver,
                                  then: @escaping () -> Void) {
        
        handler.getNumberOfPossibleCities(withPrefix: prefix) {response in
            DispatchQueue.main.async {[self] in
                let currentValue = extractDetail(from: store.state)
                store.send(.possibleCities(action: .setPossibleCitiesCount(prefix: prefix, count: response)))
                guard case .success = response else {
                    return
                }
                let requestsToMake = currentValue.values.enumerated().compactMap {(idx, value) -> Int? in
                    guard case .requested = value else {
                        return nil
                    }
                    return idx
                }
                self.requestCities(requestsToMake,
                                    prefix: prefix,
                                    handler: handler,
                                    then: then)
            }
        }
    }
    
    private func requestsToMake(oldList: [RequestableCity],
                                newList: [RequestableCity]) -> [Int] {
            let diff = newList.difference(from: oldList)
            return diff.insertions.compactMap {value in
                guard
                    case .insert(let offset, let element, _) = value,
                    case .requested = element else {
                    return nil
                }
                return offset
            }
    }
    
}
