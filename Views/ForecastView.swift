//
//  ForecastView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import SwiftUI
import RedCat



struct ForecastView : View {
    
    @EnvironmentObject var store : CombineStore<AppState, AppAction>
    
    var body : some View {
        embed(dispatchView)
    }
    
    func embed<V : View>(_ view: V) -> some View {
        GeometryReader {geo in
            VStack(spacing: 0) {
                view.frame(width: geo.size.width,
                           height: 0.9 * geo.size.height)
                tabs.animation(.easeInOut.delay(0.1).speed(0.75))
                    .frame(width: geo.size.width,
                           height: 0.1 * geo.size.height)
            }
        }
    }
    
    @ViewBuilder
    var dispatchView : some View {
        switch store.state.currentForecast.requestState {
        case .requested:
            ActivityIndicator()
        case .resolved(let response):
            forecastView(response)
        case .failed(let reason):
            Text(reason.localizedDescription)
        case .empty:
            Spacer()
        }
    }
    
    @ViewBuilder
    func forecastView(_ forecast: ResolvedForecast) -> some View {
        switch forecast {
        case .hour(let hour):
            HourView(forecast: hour)
        case .day(let day):
            DayView(forecast: day)
        case .week(let week):
            WeekView(forecast: week)
        }
    }
    
    var tabs : some View {
        GeometryReader {geo in
            HStack(spacing: 0) {
                Text("Hour")
                    .frame(width: (1/3) * geo.size.width,
                           height: geo.size.height)
                    .background(tabBackground(selected == .hour))
                    .onTapGesture {
                        showForecast(.hour)
                    }
                Text("Day")
                    .frame(width: (1/3) * geo.size.width,
                           height: geo.size.height)
                    .background(tabBackground(selected == .day))
                    .onTapGesture {
                        showForecast(.day)
                    }
                Text("Week")
                    .frame(width: (1/3) * geo.size.width,
                           height: geo.size.height)
                    .background(tabBackground(selected == .week))
                    .onTapGesture {
                        showForecast(.week)
                    }
            }.font(.headline)
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func tabBackground(_ highlighted: Bool) -> some View {
        if highlighted {
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray6),
                                                       Color.clear]),
                           startPoint: .bottom,
                           endPoint: .top).opacity(0.5)
        }
        else {
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray),
                                                       Color.clear]),
                           startPoint: .bottom,
                           endPoint: .top).opacity(0.5)
        }
    }
    
    func showForecast(_ newValue: ForecastType) {
        store.send(.forecast(action: .showForecastType(oldValue: selected,
                                            newValue: newValue)))
    }
    
    var selected : ForecastType {
        store.state.currentForecast.rawForecastType
    }
    
}



struct ForecastPreview : PreviewProvider {
    
    static var previews : some View {
        ForecastView()
            .environmentObject(AppState.makeStore {$0.currentForecast.rawForecastType = .hour})
    }
    
}
