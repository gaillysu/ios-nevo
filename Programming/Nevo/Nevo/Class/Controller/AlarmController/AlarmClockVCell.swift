//
//  AlarmClockVCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/15.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

/// Cell on main Alarm Controller

class AlarmClockVCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmSwicth: UISwitch!
    @IBOutlet weak var alarmInLabel: UILabel!
    
    var alarmItem: AlarmSectionModelItem? {
        didSet{
            alarmInLabel.text = alarmItem?.describing
            dateLabel.text = alarmItem?.alarmTimer
            titleLabel.text = alarmItem?.alarmTile
            alarmSwicth.isOn = (alarmItem?.status) == nil ? false:alarmItem!.status
        }
    }
    
    var actionCallBack:((_ sender: Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDefaultColorful()
        alarmSwicth.viewDefaultColorful()
        dateLabel.viewDefaultColorful()
        titleLabel.viewDefaultColorful()
        alarmInLabel.viewDefaultColorful()
        
        separatorInset = .zero
    }
}

// MARK: - Actions
extension AlarmClockVCell {
    @IBAction func controllManager(_ sender: Any) {
        actionCallBack?(sender)
    }
}
