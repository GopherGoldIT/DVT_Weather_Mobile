//
//  WeatherData.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let coord: Coord
    let weather: [Weather]
    let dt : Double
}

struct Main: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}

struct Coord:Codable {
    let lon: Double
    let lat: Double
}
