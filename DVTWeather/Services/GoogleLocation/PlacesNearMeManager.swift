//
//  PlacesNearMeManager.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/10.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import Foundation

protocol PlacesNearMeManagerDelegate {
    func didUpdatePlacesNearMe(_ manager: PlacesNearMeManager, places: PlacesNearMeManagerModel)
}

struct PlacesNearMeManager{
    var delegate: PlacesNearMeManagerDelegate?
    
    func GetLocations(searchKey:String = "Restaurants",radius:Int=2000,latitude:Double,longitude:Double){
        var input = GInput()
        input.keyword = searchKey
        input.radius = radius
        var location = GLocation()
        location.latitude = latitude
        location.longitude = longitude
        input.destinationCoordinate = location
        GoogleApi.shared.initialiseWithKey(GoogleLocations.provideAPIKey)
        GoogleApi.shared.callApi(.nearBy, input: input) { (response) in
            if let data = response.data as? [GApiResponse.NearBy], response.isValidFor(.nearBy){
                let places = PlacesNearMeManagerModel(location: data)
                self.delegate?.didUpdatePlacesNearMe(self,places: places)
            }
        }
    }
}
