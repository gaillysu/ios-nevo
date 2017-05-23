//
//  LinkLossNotificationsCell.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

class LinkLossNotificationsCell: UITableViewCell {

    @IBOutlet weak var localNotificationSwitch:UISwitch!
    
    var model:(cellName:String,imageName:String,setingType:SetingType)? {
        didSet{
            textLabel?.text = model?.cellName;
            imageView?.image = UIImage(named: model!.imageName)
            self.contentView.bringSubview(toFront: localNotificationSwitch)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        textLabel?.textColor = UIColor.black
        localNotificationSwitch.isOn = LocalNotificationManager.sharedInstance.getIsSendLocalMsg()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func localSwitchAction(_ sender: Any) {
        let notificationSwitch:UISwitch = sender as! UISwitch
        XCGLogger.default.debug("setIsSendLocalMsg \(notificationSwitch.isOn)")
        LocalNotificationManager.sharedInstance.setIsSendLocalMsg(notificationSwitch.isOn)
    }
    
}
