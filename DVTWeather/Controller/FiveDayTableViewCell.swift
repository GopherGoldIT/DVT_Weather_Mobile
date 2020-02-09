//
//  FiveDayTableViewCell.swift
//  DVTWeather
//
//  Created by Shaun Churchyard on 2020/02/09.
//  Copyright © 2020 Shaun Churchyard. All rights reserved.
//

import UIKit

class FiveDayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
