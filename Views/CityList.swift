//
//  CityList.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import SwiftUI
import RedCat



struct CityList : View {
    
    @EnvironmentObject var store : CombineStore<AppState, AppAction>
    
    var possibleCities : PossibleCities {
        store.state.possibleCities
    }
    
    @ViewBuilder
    var body : some View {
        switch possibleCities.requestState {
        case .requested:
            ActivityIndicator()
        case .resolved(let response):
            citiesView(response)
        case .failed(let reason):
            Text(reason.localizedDescription)
        case .empty:
            Spacer()
        }
    }
    
    @ViewBuilder
    func citiesView(_ cities: Cities) -> some View {
        
        let list = (0..<cities.list.count).map {idx in
            SingleCityRequest(index: idx,
                              prefix: possibleCities.prefix)
        }
        
        if list.isEmpty {
            Text("Not found")
        }
        
        else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(list,
                            id: \.self) {request in
                        singleCityView(index: request.index,
                                       for: cities.list[request.index])
                    }.padding()
                }
            }
        }
        
    }
    
    @ViewBuilder
    func singleCityView(index: Int, for city: RequestableCity) -> some View {
        switch city {
        case .empty:
            Spacer().onAppear {
                store.send(.possibleCities(action: .getPossibleCities(requestedIndex: index)))
            }
        case .requested:
            HStack {
                Spacer()
                Text(possibleCities.prefix)
                ActivityIndicator()
                Spacer()
            }
        case .resolved(let city):
            Text(city)
                .contentShape(Rectangle())
                .onTapGesture {
                selectCity(city)
            }
        case .failed(let reason):
            Text(reason.localizedDescription)
        }
    }
    
    func selectCity(_ city: String) {
        store.send(AppAction.showForecastForCity(oldValue: store.state.currentForecast.city,
                                    newValue: city))
    }
    
}


struct CityListPreview : PreviewProvider {
    
    static var previews : some View {
        CityList().environmentObject(store)
    }
    
    static var store : CombineStore<AppState, AppAction> {
        AppState.makeStore {state in
            state.possibleCities = PossibleCities(prefix: "B",
                                                  requestState: .resolved(response: cities))
        }
    }
    
    static var cities : Cities {
        Cities(list: [.resolved(response: "Berlin"),
                      .requested(request: SingleCityRequest(index: 1,
                                                            prefix: "B")),
                      .requested(request: SingleCityRequest(index: 2,
                                                            prefix: "B")),
                      .empty,
                      .empty])
    }
    
    
}
