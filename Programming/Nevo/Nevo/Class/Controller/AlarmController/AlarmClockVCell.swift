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
    var actionCallBack:((_ sender:Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDefaultColorful()
        dateLabel.viewDefaultColorful()
        titleLabel.viewDefaultColorful()
        alarmSwicth.viewDefaultColorful()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            alarmIn.textColor = UIColor.white
        }
    }
    
    @IBAction func controllManager(_ sender: Any) {
        actionCallBack?(sender)
    }
}
