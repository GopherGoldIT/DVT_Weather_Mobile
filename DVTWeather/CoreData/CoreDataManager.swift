//
//  CoreDataManager.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/11.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favArray = [Favourite]()
    //MARK: - Model Manuipulation
    func LoadItems() {
        let request : NSFetchRequest<Favourite> = Favourite.fetchRequest()
        request.sortDescriptors=[ NSSortDescriptor(key: "title", ascending: true)]
        do{
            self.favArray = try context.fetch(request)
            
        }catch{
            print("Error fetching context: \(error)")
            
        }
    }
    func SaveItems() {
        do{
            try context.save()
            
        }catch{
            print("Error saving context: \(error)")
            
        }
    }
    
    func  AddPrompt(viewControl : UIViewController , cityName : String , lat : Double , lon : Double){
        let latlon = "\(lat),\(lon)"
        
        let found = favArray.filter{$0.latlon == latlon}.count > 0
        if !found{
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Add new", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Add", style: .default) { (action) in
                if let text = textField.text{
                    let newFav = Favourite(context: self.context)
                    newFav.title = text
                    newFav.city = cityName
                    newFav.lat = lat
                    newFav.lon = lon
                    newFav.latlon = latlon
                    self.favArray.append(newFav)
                    self.SaveItems()
                }
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.text = cityName
                alertTextField.placeholder="Favourite name"
                textField = alertTextField
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            viewControl.present(alert, animated: true) {
            }
        }else{
            let alert = UIAlertController(title: "Already a Favourite?", message: "Sorry this location has already been added to your favourites.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            viewControl.present(alert, animated: true)
        }
    }
    
    func AttemptSaveLoaction(weather: WeatherModel ){
        let latlon = "\(weather.lat),\(weather.lon)"
        let found = favArray.filter{$0.latlon == latlon}
        for favourite in found{
            favourite.conditionId = Int32(weather.conditionId)
            favourite.lastDate = weather.date
            favourite.temperature = weather.temperature
            favourite.temperatureMin = weather.temperatureMin
            favourite.temperatureMax = weather.temperatureMax
        }
        SaveItems()
    }
}
