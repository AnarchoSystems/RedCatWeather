//
//  BottomView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import SwiftUI
import RedCat



struct BottomView : View {
    
    @EnvironmentObject var store : CombineStore<AppState>
    
    var body : some View {
        dispatchView
    }
    
    @ViewBuilder
    var dispatchView : some View {
        switch store.state.currentMenu {
        case .forecast:
            ForecastView()
        case .cities:
            ZStack {
                Color.gray.opacity(0.2)
                CityList()
            }
        }
    }
    
}
