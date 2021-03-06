//
//  WeatherModel.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit

enum WeatherConditionTypeID {
    case Sunny
    case Rainy
    case Cloudy
}

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let date : Date
    let lon: Double
    let lat: Double
    
    var title:String{
        if cityName.count != 0 {
            return cityName
        }else{
            return "\(lon),\(lat)"
        }
    }
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    var temperatureMinString: String {
        return String(format: "%.1f", temperatureMin)
    }
    var temperatureMaxString: String {
        return String(format: "%.1f", temperatureMax)
    }
    
    var WeatherConditionTypeID:WeatherConditionTypeID{
        switch conditionId {
        case 200...232:
            return .Cloudy
        case 300...321:
            return .Rainy
        case 500...531:
            return .Rainy
        case 800:
            return .Sunny
        case 801...804:
            return .Rainy
        default:
            return .Cloudy
        }
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
    
    var conditionBackgroungColor : UIColor{
        switch WeatherConditionTypeID {
        case WeatherConditionTypeID.Cloudy:
            return  #colorLiteral(red: 0.3843137255, green: 0.5215686275, blue: 0.5803921569, alpha: 1)
        case WeatherConditionTypeID.Sunny:
            return  #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)
        default:
            return  #colorLiteral(red: 0.3411764706, green: 0.3411764706, blue: 0.3647058824, alpha: 1)
        }
    }
    
}
