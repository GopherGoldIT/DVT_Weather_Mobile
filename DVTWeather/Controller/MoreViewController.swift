//
//  MoreViewController.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/10.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class MoreViewController: UIViewController {
    let regionRadius: CLLocationDistance = K.regionRadius
    var lat:Double = 0
    var lon:Double = 0
    var placesClient: GMSPlacesClient!
    
    @IBOutlet weak var mapKit: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()

        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        centerMapOnLocation(location: initialLocation)
        getLocationInformation()
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
        location.title = "Location"
        location.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapKit.addAnnotation(location)
    }
    
    func getLocationInformation(){
        //https://developers.google.com/places/ios-sdk/reference/group___place_field
        //https://github.com/waynemystir/google-places-swift/blob/master/google-places-swift/Controllers/ViewController.swift
        /*
        // A hotel in Saigon with an attribution.
        let placeId = "ChIJV4k8_9UodTERU5KXbkYpSYs"

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
          UInt(GMSPlaceField.placeID.rawValue))!

        placesClient?.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
            print("The selected place is: \(place.name)")
          }
        })*/
        
        // Specify the place data types to return.
       // let fields: GMSPlaceField = GMSPlaceField(GMSPlaceField.coordinate.rawValue(lat) )
          let fields: GMSPlaceField =   GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            for likelihood in placeLikelihoodList {
              let place = likelihood.place
              print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
              print("Current PlaceID \(String(describing: place.placeID))")
            }
          }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
