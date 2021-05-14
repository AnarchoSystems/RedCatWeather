//
//  HourView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import SwiftUI



struct HourView : View {
    
    let forecast : HourForecast
    
    var body : some View {
        ZStack {
            emoji.font(.largeTitle).scaleEffect(5)
            VStack {
                if let hour = forecast.hour {
                    Text(amPm(hour))
                }
                Text("Rain probability: \(Int(100 * forecast.rainProbability))%")
                Text("Temperature: \(Int(forecast.temperature))\(forecast.temperatureUnit.rawValue)")
            }.font(.title)
        }
    }
    
    var emoji : some View {
        Text(String(forecast.rainRange.rawValue))
    }
    
    
    func amPm(_ hour: Int) -> String {
        (0..<12).contains(hour) ? "\(hour)AM" : "\(hour % 12)PM"
    }
    
}

struct HourPreview : PreviewProvider {
    static var previews : some View {
        HourView(forecast: HourForecast(hour: 12,
                                        rainProbability: 0.2,
                                        temperature: 20,
                                        temperatureUnit: .celsius))
    }
}
