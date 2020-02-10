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
import Lottie

class WeatherViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var fiveDayForecastTable: UITableView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var favouritesButton: UIButton!
    @IBOutlet weak var lottieAnimation: UIView!
    
    var weatherManager = WeatherManager()
    var fiveDayWeatherManager = FiveDayWeatherManager()
    var currentWeather: WeatherModel?
    var fiveDayList: FiveWeatherListModel?
    let locationManager = CLLocationManager()
    
    var lat : CLLocationDegrees?
    var lon : CLLocationDegrees?
    
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        fiveDayForecastTable.dataSource = self
        fiveDayForecastTable.register(UINib(nibName: K.fiveDayNIB, bundle: nil), forCellReuseIdentifier: K.fiveDayCellReuseIdentifier)
        
        weatherManager.delegate = self
        fiveDayWeatherManager.delegate = self
        
        SetupLottie()
        SetDefault()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden=false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetLocation()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.MoreSeque
        {
            if let destinationVC = segue.destination as? MoreViewController {
                if let geoLat = lat,let geoLon = lon{
                    destinationVC.SetLocation(geoLat,geoLon)
                }
            }
        }
    }
    // MARK: - Custom UI
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
        ShowLottie()
        locationManager.requestLocation()
    }
    
    func SetDefault(){
        self.temperatureLabel.attributedText = DegAttributeText("0",self.temperatureLabel.font,self.temperatureLabel.textColor)
        self.conditionImage.image = UIImage(systemName: "sun.max")
        self.cityLabel.text = ""
        self.conditionLabel.text = ""
        self.backgroundView.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.6705882353, blue: 0.1843137255, alpha: 1)
        self.moreButton.isEnabled = false
        self.favouritesButton.isEnabled = false
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
        HideLottie()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}
//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.currentWeather = weather
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
        HideLottie()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}
//MARK: - FiveDayWeatherManagerDelegate
extension WeatherViewController: FiveDayWeatherManagerDelegate {
    
    func didUpdateFiveDayWeather(_ fiveDayeatherManager: FiveDayWeatherManager, weather: FiveWeatherListModel) {
        DispatchQueue.main.async {
            self.fiveDayList = weather;
            self.fiveDayForecastTable.reloadData()
            self.moreButton.isEnabled = true
            self.HideLottie()
        }
    }
    
    func didFailWithErrorFiveDayWeather(error: Error) {
        SetDefault()
        HideLottie()
        self.cityLabel.text = "Error : " + error.localizedDescription
    }
}
//MARK: - UITableViewDataSource
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
//MARK: - LottieFunctions
extension WeatherViewController{
    func SetupLottie(){
        let animation = Animation.named(K.lottieLoadingAnimation)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        lottieAnimation.addSubview(animationView)
        //lottieAnimation.isHidden=true
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: lottieAnimation.layoutMarginsGuide.topAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: lottieAnimation.leadingAnchor).isActive = true
        
        animationView.bottomAnchor.constraint(equalTo: lottieAnimation.bottomAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: lottieAnimation.trailingAnchor).isActive = true
        
        animationView.backgroundBehavior = .pauseAndRestore
        
    }
    func ShowLottie(){
        DispatchQueue.main.async {
            self.lottieAnimation.isHidden=false
            self.animationView.play()
        }
    }
    func HideLottie(){
        DispatchQueue.main.async {
            self.animationView.stop()
            self.lottieAnimation.isHidden=true
        }
    }
    
}

