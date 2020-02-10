//
//  ViewController.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit
import CoreLocation
import BonMot

class WeatherViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var fiveDayForecastTable: UITableView!
    
    var weatherManager = WeatherManager()
    var fiveDayWeatherManager = FiveDayWeatherManager()
    
    var fiveDayList: FiveWeatherListModel?
    let locationManager = CLLocationManager()
    
    var lat : CLLocationDegrees?
    var lon : CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        fiveDayForecastTable.delegate = self
        fiveDayForecastTable.dataSource = self
        fiveDayForecastTable.register(UINib(nibName: K.fiveDayNIB, bundle: nil), forCellReuseIdentifier: K.fiveDayCellReuseIdentifier)
        
        weatherManager.delegate = self
        fiveDayWeatherManager.delegate = self
        SetDefault()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetLocation()
    }
    
    func DegAttributeText(_ text:String,_ fontBase:UIFont, _ color:UIColor )->NSAttributedString{
        let garamondStyle = StringStyle(
            .font(.systemFont(ofSize: fontBase.pointSize)!),
            .color(color),
            .lineHeightMultiple(1.2),
            .adapt(.body)
        )
        let decimalStyle = StringStyle(
            .font(.systemFont(ofSize: fontBase.pointSize/2)!),
            .color(color),
            .lineHeightMultiple(1.2),
            .baselineOffset(6),
            .adapt(.body)
        )
        let string = "\(text)<ordinal> 0</ordinal>"
        return string.styled(with: garamondStyle.byAdding(
            .xmlRules([
                .style("ordinal", decimalStyle.byAdding(.ordinals(true))),
                ])
            )
        )
    }
    
    func GetLocation(){
        locationManager.requestLocation()
    }
    
    func SetDefault(){
        self.temperatureLabel.attributedText = DegAttributeText("0",self.temperatureLabel.font,self.temperatureLabel.textColor)
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
            self.temperatureLabel.attributedText = self.DegAttributeText(weather.temperatureString,self.temperatureLabel.font,self.temperatureLabel.textColor)
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.title
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
    
    func didUpdateFiveDayWeather(_ fiveDayeatherManager: FiveDayWeatherManager, weather: FiveWeatherListModel) {
        DispatchQueue.main.async {
            self.fiveDayList = weather;
            self.fiveDayForecastTable.reloadData()
        }
    }
    
    func didFailWithErrorFiveDayWeather(error: Error) {
        SetDefault()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}

extension WeatherViewController:UITableViewDelegate{
    
}
extension WeatherViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.fiveDayCellReuseIdentifier , for: indexPath) as! FiveDayTableViewCell
        if let fiveDay = fiveDayList{
            cell.dayLabel.text = fiveDay.list[indexPath.row].dateString
            cell.conditionImage.image =  UIImage(systemName: fiveDay.list[indexPath.row].conditionName)
            cell.tempretureLabel.attributedText = self.DegAttributeText(fiveDay.list[indexPath.row].temperatureString,cell.tempretureLabel.font,cell.tempretureLabel.textColor)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fiveDay = fiveDayList{
            return fiveDay.list.count
        }else{
            return 0
        }
    }
}



