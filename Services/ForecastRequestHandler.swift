//
//  ForecastRequestHandler.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 13.05.21.
//

import Foundation
import RedCat


enum ForecastRequestHandler : Config {
    static func value(given: Dependencies) -> ForecastRequestResolver {
        if given.debug {
            return MockForecastResolver(delay: given.debugDelay)
        }
        else {
            fatalError("Not implemented")
        }
    }
}

protocol ForecastRequestResolver {
    
    func forecast(for city: String,
                  type: ForecastType,
                  response: @escaping (Result<ResolvedForecast, NSError>) -> Void)
    
}

extension Dependencies {
    
    var forecastRequestHandler : ForecastRequestResolver {
            self[ForecastRequestHandler.self]
    }
    
}


class ForecastRequestService : DetailService<AppState, Forecast> {
    
    override func onUpdate(newValue: Forecast, store: Store<AppState>, environment: Dependencies) {
        guard case .requested(let request) = newValue.requestState else {
            return
        }
        
        var answered = false
        
        environment.forecastRequestHandler.forecast(for: newValue.city,
                                                    type: request) {[weak store, weak self] response in
            DispatchQueue.main.async {
                answered = true
                guard
                    let store = store,
                    let value = self?.detail(store.state),
                    value == newValue else {
                    return
                }
                store.send(Actions.Forecast.RespondWithForecast(city: value.city, payload: response))
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {[weak store] in
            guard !answered else {return}
            store?.send(Actions.Error.SetError(error: environment.slowInternetWarning.makeNSError()))
        }
    }
    
}


struct MockForecastResolver : ForecastRequestResolver {
    
    let delay : DebugDelay
    let week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    func forecast(for city: String,
                  type: ForecastType,
                  response: @escaping (Result<ResolvedForecast, NSError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.random(in: delay.delayMs))) {
            switch type {
            case .hour:
                response(.success(.hour(randomHourForecast())))
            case .day:
                response(.success(.day(DayForecast(day: week.randomElement()!, hourly: forecasts(count: 24)))))
            case .week:
                let forecast = forecasts(count: 7 * 24)
                let days = (0..<7).map {DayForecast(day: week[$0], hourly: Array(forecast[$0 * 24..<($0 + 1) * 24]))}
                response(.success(.week(WeekForecast(daily: days))))
            }
        }
    }
    
    func forecasts(count: Int) -> [HourForecast] {
        (0..<count - 1).reduce(into: [randomHourForecast()]) { last, _ in
            last.append(randomHourForecast(seed: last.last))
        }
    }
    
    func randomHourForecast(seed: HourForecast? = nil) -> HourForecast {
        guard let seed = seed else {
            return HourForecast(hour: 0,
                                rainProbability: .random(in: 0...1),
                                temperature: .random(in: -10...30),
                                temperatureUnit: .celsius)
        }
        return HourForecast(hour: ((seed.hour ?? 0) + 1) % 24,
                            rainProbability: min(1, max(0, seed.rainProbability + .random(in: -0.1...0.1))),
                            temperature: min(30, max(-10, seed.temperature + .random(in: -2...2))),
                            temperatureUnit: .celsius)
    }
    
}
