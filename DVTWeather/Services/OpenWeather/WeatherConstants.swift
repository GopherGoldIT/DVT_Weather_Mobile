//
//  WeatherConstants.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation

struct Openweathermap{
    static let app_key = "appid=key" //your key from https://openweathermap.org/appid
    static let base = "https://api.openweathermap.org/data/2.5/weather"
    static let baseFiveDay = "https://api.openweathermap.org/data/2.5/forecast"
    static let units = "&units=metric"
    static let limit = "&cnt=5"
}
