//
//  AlarmClockVCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/15.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockVCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmSwicth: UISwitch!
    @IBOutlet weak var alarmIn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
