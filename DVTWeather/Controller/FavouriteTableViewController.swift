//
//  FavouriteTableViewController.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit

class FavouriteTableViewController: UITableViewController {
    let coreDataManager = CoreDataManager()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataManager.LoadItems()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataManager.favArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.favCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = coreDataManager.favArray[indexPath.row].title
        if let date = coreDataManager.favArray[indexPath.row].lastDate{
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.detailTextLabel?.text = coreDataManager.favArray[indexPath.row].latlon! + " / " + dateFormatterPrint.string(from: date)
        }else{
            cell.detailTextLabel?.text = coreDataManager.favArray[indexPath.row].latlon!
        }
        
        return cell
    }
}

