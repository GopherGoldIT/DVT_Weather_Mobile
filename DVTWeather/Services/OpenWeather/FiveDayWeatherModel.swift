//
//  FiveDayWeatherModel.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation

struct FiveWeatherListModel {
    let list : [FiveWeatherModel]
}

struct FiveWeatherModel {
    let conditionId: Int
    let temperature: Double
    let date : Date
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
    var conditionLabel: String {
        switch conditionId {
        case 200...232:
            return "Thunder"
        case 300...321:
            return "Drizzle"
        case 500...531:
            return "Rain"
        case 600...622:
            return "Snow"
        case 701...781:
            return "Fog"
        case 800:
            return "Sunny"
        case 801...804:
            return "Thunder"
        default:
            return "Cloudy"
        }
    }
}
