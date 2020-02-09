//
//  ViewController.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    var weatherManager = WeatherManager()
    var fiveDayWeatherManager = FiveDayWeatherManager()
    let locationManager = CLLocationManager()
    
    var lat : CLLocationDegrees?
    var lon : CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        fiveDayWeatherManager.delegate = self
        SetDefault()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetLocation()
    }
    
    func GetLocation(){
        locationManager.requestLocation()
    }
    
    func SetDefault(){
        self.temperatureLabel.text = "0"
        self.conditionImage.image = UIImage(systemName: "sun.max")
        self.cityLabel.text = ""
        self.conditionLabel.text = ""
        self.backgroundView.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.6705882353, blue: 0.1843137255, alpha: 1)
    }
}

//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        GetLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat!, longitude: lon!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        SetDefault()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}
//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            self.conditionLabel.text = weather.conditionLabel
            self.backgroundView.backgroundColor = weather.conditionBackgroungColor
            if let lat = self.lat, let lon = self.lon{
                self.fiveDayWeatherManager.fetchWeather(latitude: lat, longitude: lon)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        SetDefault()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}
//MARK: - FiveDayWeatherManagerDelegate
extension WeatherViewController: FiveDayWeatherManagerDelegate {
    
    func didUpdateFiveDayWeather(_ fiveDayeatherManager: FiveDayWeatherManager, weather: FiveDayWeatherData) {
        DispatchQueue.main.async {
            print(weather)
          /*  for weather in weather.list{
                
            }*/
           // self.temperatureLabel.text = weather.temperatureString
        }
    }
    
    func didFailWithErrorFiveDayWeather(error: Error) {
        SetDefault()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}



