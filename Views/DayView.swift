//
//  DayView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import SwiftUI



struct DayView : View {
    
    let forecast : DayForecast
    
    var body : some View {
        GeometryReader {geo in
            VStack(spacing: 0) {
                HourView(forecast: forecast.average)
                    .frame(width: geo.size.width,
                           height: 0.4 * geo.size.height)
                Divider()
                list.frame(width: geo.size.width,
                           height: 0.6 * geo.size.height)
            }
        }
    }
    
    var list : some View {
        ScrollView {
            ForEach(forecast.hourly, id: \.self, content: hourView)
        }.padding()
    }
    
    func hourView(_ hour: HourForecast) -> some View {
        GeometryReader {geo in
            HStack(spacing: 0) {
                Text(hour.hour.map(amPm) ?? "?")
                    .frame(width: (1/3) * geo.size.width,
                           height: geo.size.height)
                Text("\(Int(hour.temperature))\(hour.temperatureUnit.rawValue)")
                        .frame(width: (1/3) * geo.size.width,
                               height: geo.size.height)
                Text(String(RainRange(rainProbability: hour.rainProbability).rawValue))
                        .frame(width: (1/3) * geo.size.width,
                               height: geo.size.height)
            }
        }.padding()
    }
    
    func amPm(_ hour: Int) -> String {
        (0..<12).contains(hour) ? "\(hour)AM" : "\(hour % 12)PM"
    }
    
}

struct DayPreview : PreviewProvider {
    
    static var previews : some View {
        DayView(forecast: DayForecast(day: "Sunday",
                                      hourly: hours))
    }
    
    static var hours : [HourForecast] {
        (0..<24).map {hour in
            HourForecast(hour: hour,
                         rainProbability: 0.2,
                         temperature: 20,
                         temperatureUnit: .celsius)
        }
    }
    
}
