//
//  WorldClockCell.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class WorldClockCell: UITableViewCell {
    
    @IBOutlet weak var worldTimeLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }
    
    
    func setTime(worldTime:String, sunriseTime:String, sunsetTime:String) {
        worldTimeLabel.text = worldTime
        sunriseLabel.text = sunriseTime
        sunsetLabel.text = sunsetTime
    }
}
