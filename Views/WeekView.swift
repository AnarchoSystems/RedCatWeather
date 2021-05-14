//
//  WeekView.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import SwiftUI



struct WeekView : View {
    
    let forecast : WeekForecast
    
    var body : some View {
        GeometryReader {geo in
            ScrollView {
                VStack {
                    ForEach(forecast.daily, id: \.self, content: dayView)
                }.frame(width: geo.size.width,
                       height: geo.size.height)
            }
        }
    }
    
    func dayView(_ day: DayForecast) -> some View {
        GeometryReader {geo in
            let hour = day.average
            HStack(spacing: 0) {
                Text(day.day)
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
    
}


struct WeekPreview : PreviewProvider {
    
    static var previews : some View {
        WeekView(forecast: forecast)
    }
    
    static var forecast : WeekForecast {
        WeekForecast(daily: week.map(dayForecast))
    }
    
    static var week : [String] {
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    }
    
    static func dayForecast(_ day: String) -> DayForecast {
        DayForecast(day: day,
                    hourly: hours)
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
