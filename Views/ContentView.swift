//
//  ContentView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 12.05.21.
//

import SwiftUI
import RedCat


struct ContentView: View {
    
    @EnvironmentObject var store : CombineStore<AppState>
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            GeometryReader {geo in
                VStack(spacing: 0) {
                    cityView
                        .frame(width: geo.size.width,
                               height: 0.2 * geo.size.height)
                    bottomView
                        .frame(width: geo.size.width,
                               height: 0.8 * geo.size.height)
                }
            }.ignoresSafeArea(.container, edges: .bottom)
        }.transition(.slide).animation(.linear)
        .alert(isPresented: isErrorPresented) {
            Alert(title: Text(store.state.error!.value.localizedDescription),
                  message: Text(store.state.error!.value.localizedRecoverySuggestion ?? "Try crying."),
                  dismissButton: .default(Text("Ok")))
        }
    }
    
    var cityView : some View {
        CityView()
    }
    
    var bottomView : some View {
        BottomView()
    }
    
    var isErrorPresented : Binding<Bool> {
        Binding(get: {store.state.error != nil},
                set: {if !$0 {store.send(Actions.DismissError())}})
    }
    
    var errorBinding : Binding<Identified<UUID, NSError>?> {
        Binding(get: {store.state.error},
                set: {if $0 == nil {store.send(Actions.DismissError())}})
    }
    
    @ViewBuilder
    var background : some View {
        switch store.state.currentMenu {
        case .forecast:
            forecastBackground
        case .cities:
            Color(UIColor.systemBlue)
        }
    }
    
    @ViewBuilder
    var forecastBackground : some View {
        if let lastResult = store.state.currentForecast.lastResult {
            lastResult.rainRange.color
        }
        else if case .resolved(let forecast) = store.state.currentForecast.requestState {
            forecast.rainRange.color
        }
        else {
            RainRange.sunny.color
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.makeStore())
    }
}
