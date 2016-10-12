//
//  AddAlarmTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddAlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.datePickerMode = UIDatePickerMode.time;
        datePicker.addTarget(self, action: #selector(AddAlarmTableViewCell.selectedTimerAction(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            datePicker.backgroundColor = UIColor.getGreyColor()
            datePicker.tintColor = UIColor.white
            datePicker.setValue(UIColor.white, forKey: "textColor")
        }
    }

    func selectedTimerAction(_ timer:UIDatePicker){

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
