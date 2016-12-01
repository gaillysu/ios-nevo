//
//  AllowNotificationsTableViewCell.swift
//  Nevo
//
//  Created by Cloud on 2016/12/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class AllowNotificationsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var allowSwitch: UISwitch!
    var addDelegate:AddPacketToWatchDelegate?
    var notificationSetting:NotificationSetting?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func allowSwitchAction(_ sender: Any) {
        let swicthState:UISwitch = sender as! UISwitch
        addDelegate?.addPacketToWatchDelegate(appid: notificationSetting!.getPacket(), onOff: swicthState.isOn)
    }
    
    func setAllowSwitch(color:UIColor,isOn:Bool) {
        allowSwitch.tintColor = color
        allowSwitch.onTintColor = color
        allowSwitch.isOn = isOn
    }
    func setTitleLabel(title:String,titleColor:UIColor,titleFont:UIFont?) {
        titleLabel.text = title
        titleLabel.textColor = titleColor
        if titleFont != nil {
            titleLabel.font = titleFont
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
