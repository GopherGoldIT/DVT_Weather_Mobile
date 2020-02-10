//
//  MoreViewController.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/10.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit
import MapKit

class MoreViewController: UIViewController{
    let regionRadius: CLLocationDistance = K.mapRegionRadius
    var lat:Double = 0
    var lon:Double = 0
    
    var placesNearMe = PlacesNearMeManager()
    var places: PlacesNearMeManagerModel?
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var placesTable: UITableView!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesNearMe.delegate = self
        placesTable.dataSource = self
        placesTable.delegate = self
        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        centerMapOnLocation(location: initialLocation)
        getLocationInformation()
        headingLabel.text=K.nearMeSearchFor
    }
    
    func SetLocation(_ lon:Double,_ lat:Double){
        self.lat=lat
        self.lon=lon
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapKit.setRegion(coordinateRegion, animated: true)
        
        let location = MKPointAnnotation()
        location.title = K.nearMeLocationCaption
        location.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapKit.addAnnotation(location)
    }
    
    func getLocationInformation(){
        placesNearMe.GetLocations(searchKey: K.nearMeSearchFor, radius: K.searchRegionRadius, latitude: lat, longitude: lon)
    }
    
    func AddExtraAnnotation(row:Int){
        mapKit.removeAnnotations(mapKit.annotations)
        
        let location = MKPointAnnotation()
        location.title = K.nearMeLocationCaption
        location.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapKit.addAnnotation(location)
        
        if let pLon = places!.location[row].location.longitude, let pLat = places!.location[row].location.latitude{
            let pointLocation = MKPointAnnotation()
            pointLocation.title = places!.location[row].formattedAddress
            pointLocation.coordinate = CLLocationCoordinate2D(latitude: pLat, longitude: pLon)
            mapKit.addAnnotation(pointLocation)
        }
    }
}

//MARK: - UITableViewDataSource
extension MoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (places==nil){
            return 0
        }else{
            return places!.location.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.nearMeCellReuseIdentifier , for: indexPath)
        cell.textLabel?.text = places!.location[indexPath.row].formattedAddress
        cell.detailTextLabel?.text = places!.location[indexPath.row].description
        return cell
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AddExtraAnnotation(row:indexPath.row)
    }
}

//MARK: - FiveDayWeatherManagerDelegate
extension MoreViewController: PlacesNearMeManagerDelegate {
    func didUpdatePlacesNearMe(_ manager: PlacesNearMeManager, places: PlacesNearMeManagerModel) {
        self.places = places
        DispatchQueue.main.async {
            self.placesTable.reloadData()
        }
    }
}



