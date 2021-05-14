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
        if given.debug {
            return MockCityResolver(delay: given.debugDelay)
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


class CityRequestService : DetailService<AppState, PossibleCities> {
    
    override func onUpdate(newValue: PossibleCities, store: Store<AppState>, environment: Dependencies) {
        
        var answered = false
        
        switch newValue.requestState {
        
        case .empty, .failed:
            return
            
        case .requested(let request):
            requestCityCount(prefix: request,
                             store: store,
                             handler: environment.cityRequestHandler,
                             then: {answered = true})
            
        case .resolved(let list):
            let requests = requestsToMake(oldList: oldValue?.values ?? [],
                                          newList: list.list)
            
            requestCities(requests,
                          prefix: newValue.prefix,
                          store: store,
                          handler: environment.cityRequestHandler,
                          then: {answered = true})
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {[weak store] in
            guard !answered else {return}
            store?.send(Actions.SetError(error: environment.slowInternetWarning.makeNSError()))
        }
        
    }
    
    private func requestCities(_ indices: [Int],
                               prefix: String,
                               store: Store<AppState>,
                               handler: CityRequestResolver,
                               then: @escaping () -> Void) {
        
        handler.getPossibleCities(withPrefix: prefix, indices: indices) {[weak store] response in
            DispatchQueue.main.async {
                store?.send(Actions.SetPossibleCities(prefix: prefix, values: Array(zip(indices, response))))
                then()
            }
        }
        
    }
    
    private func requestCityCount(prefix: String,
                                  store: Store<AppState>,
                                  handler: CityRequestResolver,
                                  then: @escaping () -> Void) {
        
        handler.getNumberOfPossibleCities(withPrefix: prefix) {response in
            DispatchQueue.main.async {[weak store, weak self] in
                guard
                    let detail = self?.detail,
                    let store = store else {
                    return
                }
                let currentValue = detail(store.state)
                store.send(Actions.SetPossibleCitiesCount(prefix: prefix, count: response))
                guard case .success = response else {
                    return
                }
                let requestsToMake = currentValue.values.enumerated().compactMap {(idx, value) -> Int? in
                    guard case .requested = value else {
                        return nil
                    }
                    return idx
                }
                self?.requestCities(requestsToMake,
                                    prefix: prefix,
                                    store: store,
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
