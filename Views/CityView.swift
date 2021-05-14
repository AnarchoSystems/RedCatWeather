//
//  CityView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import SwiftUI
import RedCat



struct CityView : View {
    
    @EnvironmentObject var store : CombineStore<AppState>
    
    @ViewBuilder
    var body: some View {
        switch store.state.currentMenu {
        case .forecast:
            usualView
        case .cities:
            browsingView.padding()
        }
    }
    
    var browsingView : some View {
        CityTextField()
    }
    
    var usualView : some View {
        GeometryReader {geo in
            HStack(spacing: 0) {
                Text(store.state.currentForecast.city)
                    .font(.largeTitle)
                    .padding()
                    .onTapGesture(perform: startCityBrowsing)
                    .frame(width: (2/3) * geo.size.width,
                           height: geo.size.height,
                           alignment: .trailing)
                Image(systemName: "magnifyingglass.circle")
                    .imageScale(.large)
                    .scaleEffect(1.5)
                    .padding()
                    .onTapGesture(perform: startCityBrowsing)
                    .frame(width: (1/3) * geo.size.width,
                           height: geo.size.height,
                           alignment: .leading)
            }
        }
    }
    
    func startCityBrowsing() {
        store.send(Actions.GetPossibleCitiesCount(prefix: store.state.currentForecast.city))
    }
    
}
