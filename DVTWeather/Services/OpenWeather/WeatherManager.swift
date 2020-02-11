//
//  WeatherManager.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation
import CoreLocation

enum WeatherManagerError: Error {
    case key
}

extension WeatherManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .key:
            return "Please insert key for openweathermap"
        }
    }
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "\(Openweathermap.base)?\(Openweathermap.app_key)\(Openweathermap.units)"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if Openweathermap.app_key != "appid=key" {
            let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
            print(urlString)
            performRequest(with: urlString)
        }else{
            delegate?.didFailWithError(error: WeatherManagerError.key)
        }
    }
    
    func fetchWeatherDouble(latitude: Double, longitude: Double) {
        if Openweathermap.app_key != "appid=key" {
            let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
            performRequest(with: urlString)
        }else{
            delegate?.didFailWithError(error: WeatherManagerError.key)
        }
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let tempMin = decodedData.main.temp_min
            let tempMax = decodedData.main.temp_max
            let name = decodedData.name
            let date = Date(timeIntervalSince1970: decodedData.dt)
            let lon = decodedData.coord.lon
            let lat = decodedData.coord.lat
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp,temperatureMin: tempMin,temperatureMax: tempMax, date:date,lon:lon,lat:lat)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
