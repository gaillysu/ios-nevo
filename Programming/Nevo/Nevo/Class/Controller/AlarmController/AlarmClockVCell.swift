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
        // Initialization code
    }
    
    override func layoutSubviews() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getGreyColor()
            contentView.backgroundColor = UIColor.getGreyColor()
            dateLabel.textColor = UIColor.white
            titleLabel.textColor = UIColor.white
            alarmIn.textColor = UIColor.white
            alarmSwicth.onTintColor = UIColor.getBaseColor()
        }else{
            contentView.backgroundColor = UIColor.white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func controllManager(_ sender: Any) {
        actionCallBack?(sender)
    }
}
