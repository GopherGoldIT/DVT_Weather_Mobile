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
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var addFavButton: UIButton!
    
    var weatherManager = WeatherManager()
    var fiveDayWeatherManager = FiveDayWeatherManager()
    var currentWeather: WeatherModel?
    var fiveDayList: FiveWeatherListModel?
    let locationManager = CLLocationManager()
    
    var lat : CLLocationDegrees?
    var lon : CLLocationDegrees?
    
    var exactLat : Double?
    var exactLon : Double?
    
    var isFav:Bool=false
    
    let animationView = AnimationView()
    
    var coreDataManager = CoreDataManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        isFav = false
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
        coreDataManager.LoadItems()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden=false
    }
    
    @IBAction func favButtonClick(_ sender: UIButton) {
        if let weather = self.currentWeather {
            coreDataManager.AddPrompt(viewControl: self, cityName: currentWeather!.cityName, lat: currentWeather!.lat, lon: currentWeather!.lon, exactLat:Double(lat ?? 0),exactLon:Double(lon ?? 0),currentWeather:weather)
        }
    }
    @IBAction func navButtonClick(_ sender: UIButton) {
        GetLocation()
    }
    override func viewDidAppear(_ animated: Bool) {
        if (lat==nil)&&(exactLat==nil)
        {
            GetLocation()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.MoreSeque
        {
            if let destinationVC = segue.destination as? MoreViewController {
                if let geoLat = lat,let geoLon = lon{
                    destinationVC.SetLocation(geoLon,geoLat)
                }
            }
        }
    }
    
    func GetLocation(){
        ShowLottie()
        locationManager.requestLocation()
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
        self.currentWeather = weather
        self.checkSaveWeatherManager()
        self.showWeatherManager()
    }
    
    func didFailWithError(error: Error) {
        let errorCode = (error as NSError).code
        if errorCode == K.OfflineErrorCode{
            let favouriteArray = coreDataManager.tryFind(lat:lat , lon: lon, exactLat: exactLat, exactLon: exactLon)
            if (favouriteArray.count == 0){
                SetDefault()
                DispatchQueue.main.async {
                    self.cityLabel.text = "Error : " + error.localizedDescription
                }
            }else{
                let fav = favouriteArray[0]
                if fav.lastDate != nil{
                    self.currentWeather = WeatherModel(conditionId: Int(fav.conditionId), cityName: "", temperature: fav.temperature, temperatureMin: fav.temperatureMin, temperatureMax: fav.temperatureMax, date: fav.lastDate!, lon: fav.lon, lat: fav.lat)
                    
                    showWeatherManager(false)
                }
            }
        }else{
            SetDefault()
            DispatchQueue.main.async {
                self.cityLabel.text = "Error : " + error.localizedDescription
            }
        }
        HideLottie()
    }
    
    func showWeatherManager(_ enableSave : Bool = true){
        if let weather = self.currentWeather {
            DispatchQueue.main.async {
                self.temperatureLabel.attributedText = self.DegAttributeTextHeading(weather.temperatureString,self.temperatureLabel.font,self.temperatureLabel.textColor)
                
                self.cityLabel.text = weather.title
                self.conditionLabel.text = weather.conditionLabel
                self.backgroundView.backgroundColor = weather.conditionBackgroungColor
                if let navController = self.navigationController {
                    navController.navigationBar.barTintColor = weather.conditionBackgroungColor
                }
                self.minLabel.attributedText = self.DegAttributeText(weather.temperatureMinString,self.minLabel.font,self.minLabel.textColor)
                self.currentLabel.attributedText = self.DegAttributeText(weather.temperatureString,self.currentLabel.font,self.currentLabel.textColor)
                self.maxLabel.attributedText = self.DegAttributeText(weather.temperatureMaxString,self.maxLabel.font,self.maxLabel.textColor)
                if enableSave {
                    self.addFavButton.isEnabled = true
                    if let lat = self.lat, let lon = self.lon{
                        self.fiveDayWeatherManager.fetchWeather(latitude: lat, longitude: lon)
                    }
                }
                
                switch weather.WeatherConditionTypeID {
                case WeatherConditionTypeID.Cloudy:
                    self.conditionImage.image = UIImage(named: "sea_cloudy")
                    return
                case WeatherConditionTypeID.Sunny:
                    self.conditionImage.image = UIImage(named: "sea_sunnypng")
                    return
                default:
                    self.conditionImage.image = UIImage(named: "sea_rainy")
                }
            }
        }
    }
    
    func checkSaveWeatherManager(){
        if let weather = self.currentWeather {
            coreDataManager.AttemptSaveLoaction(weather: weather)
        }
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
        DispatchQueue.main.async {
            self.cityLabel.text = "Error : " + error.localizedDescription
        }
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
        cell.layer.backgroundColor = UIColor.clear.cgColor
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

// MARK: - Custom UI
extension WeatherViewController{
    // MARK: - Custom UI
    func DegAttributeText(_ text:String,_ fontBase:UIFont, _ color:UIColor )->NSAttributedString{
        let garamondStyle = StringStyle(
            .alignment(.center),
            .font(.systemFont(ofSize: fontBase.pointSize)),
            .color(color),
            .lineHeightMultiple(1.0),
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
            ]))
        )
    }
    func DegAttributeTextHeading(_ text:String,_ fontBase:UIFont, _ color:UIColor )->NSAttributedString{
        let garamondStyle = StringStyle(
            .alignment(.center),
            .font(.systemFont(ofSize: fontBase.pointSize)),
            .color(color),
            .lineHeightMultiple(1.0),
            .adapt(.body)
            
        )
        let decimalStyle = StringStyle(
            .font(.systemFont(ofSize: fontBase.pointSize/2)!),
            .color(color),
            .lineHeightMultiple(1.2),
            .baselineOffset(18),
            .adapt(.body)
        )
        let string = "\(text)<ordinal> 0</ordinal>"
        return string.styled(with: garamondStyle.byAdding(
            .xmlRules([
                .style("ordinal", decimalStyle.byAdding(.ordinals(true))),
            ]))
        )
    }
    
    func SetDefault(){
        DispatchQueue.main.async {
            self.addFavButton.isEnabled=false
            self.temperatureLabel.attributedText = self.DegAttributeTextHeading("0",self.temperatureLabel.font,self.temperatureLabel.textColor)
            self.conditionImage.image = UIImage(named: "sea_cloudy")
            self.cityLabel.text = ""
            self.conditionLabel.text = ""
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.4431372549, blue: 0.4784313725, alpha: 1)
            if let navController = self.navigationController {
                navController.navigationBar.barTintColor =  self.backgroundView.backgroundColor
            }
            self.moreButton.isEnabled = false
            
            self.minLabel.text = "-"
            self.currentLabel.text = "-"
            self.maxLabel.text = "-"
            
            self.fiveDayList = nil
            self.fiveDayForecastTable.reloadData()
        }
    }
}

extension WeatherViewController{
    func loadFrom(_ favourite:Favourite){
        lat=nil
        lon=nil
        exactLat = favourite.exactLat
        exactLon = favourite.exactLon
        SetDefault()
        weatherManager.fetchWeatherDouble(latitude: favourite.exactLat, longitude: favourite.exactLon)
    }
}


