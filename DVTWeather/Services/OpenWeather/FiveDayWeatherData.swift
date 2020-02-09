//
//  FiveDayWeatherData.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation

struct FiveDayWeatherData: Codable {
    let list: [FiveDayInnerWeatherData]
}

struct FiveDayInnerWeatherData: Codable {
    let main: FiveDayMain
    let weather: [FiveDayWeather]
    let dt : Double
}

struct FiveDayMain: Codable {
    let temp: Double
}

struct FiveDayWeather: Codable {
    let description: String
    let id: Int
}
