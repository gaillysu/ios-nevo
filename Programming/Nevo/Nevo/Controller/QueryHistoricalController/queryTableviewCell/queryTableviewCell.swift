//
//  queryTableviewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class queryTableviewCell: UITableViewCell {


    @IBOutlet weak var deepSleepTime: UILabel!
    @IBOutlet weak var sleepTime: UILabel!
    @IBOutlet weak var wakeTime: UILabel!
    @IBOutlet weak var lightTime: UILabel!
    @IBOutlet weak var dailyDist: UILabel!
    @IBOutlet weak var dailyCalories: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
