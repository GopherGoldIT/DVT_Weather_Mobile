//
//  FiveDayWeatherManager.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation
import CoreLocation

protocol FiveDayWeatherManagerDelegate {
    func didUpdateFiveDayWeather(_ fiveDayeatherManager: FiveDayWeatherManager, weather: FiveWeatherListModel)
    func didFailWithErrorFiveDayWeather(error: Error)
}

struct FiveDayWeatherManager {
    
let weatherURL = "\(Openweathermap.baseFiveDay)?\(Openweathermap.app_key)\(Openweathermap.units)"
var delegate: FiveDayWeatherManagerDelegate?

func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    if Openweathermap.app_key != "appid=key" {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }else{
        delegate?.didFailWithErrorFiveDayWeather(error: WeatherManagerError.key)
    }
}
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithErrorFiveDayWeather(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateFiveDayWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> FiveWeatherListModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FiveDayWeatherData.self, from: weatherData)
            var list : [FiveWeatherModel] = [];
            for forecast in decodedData.list {
                let id = forecast.weather[0].id
                let temp = forecast.main.temp
                let date = Date(timeIntervalSince1970: forecast.dt)
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                if (11 ... 13).contains(hour){
                    let weather = FiveWeatherModel(conditionId: id, temperature: temp, date: date)
                    list.append(weather)
                }
            }
            return FiveWeatherListModel(list: list)
        } catch {
            delegate?.didFailWithErrorFiveDayWeather(error: error)
            return nil
        }
    }
}
