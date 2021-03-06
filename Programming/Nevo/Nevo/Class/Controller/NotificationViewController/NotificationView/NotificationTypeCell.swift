//
//  NotificationTypeCell.swift
//  Nevo
//
//  Created by Cloud on 2016/11/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

protocol AddPacketToWatchDelegate {
    
    func addPacketToWatchDelegate(appid:String,onOff:Bool)
}

class NotificationTypeCell: UITableViewCell {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var addSwitch: UISwitch!
    var addDelegate:AddPacketToWatchDelegate?
    
    
    var notificationSetting:NotificationSetting?{
        didSet{
        
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImage.layer.cornerRadius = 7
        titleImage.layer.masksToBounds = true
        
        addSwitch.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSwitchState(_ on:Bool) {
        addSwitch.setOn(on, animated: false)
    }
    
    func getSwitchState()->Bool {
        return addSwitch.isOn
    }
    
    func setTitleLabel(title:String) {
        let titleString:String = title.replacingOccurrences(of: "WeChat", with: "Whatsapp")
        titleLabel.text = NSLocalizedString(titleString, comment: "")
    }
    
    func setContentLabel(content:String) {
        contentLabel.text = content
    }
    
    func setTitleImage(imageName:String) {
        let mImageName:String = imageName.replacingOccurrences(of: "wechat", with: "whatsapp")
        titleImage.image = UIImage(named: mImageName)
    }
    
    @IBAction func addNotificationAction(_ sender: Any) {
        let swicthState:UISwitch = sender as! UISwitch
        let mNotificationArray:[MEDUserNotification] = MEDUserNotification.getAll() as! [MEDUserNotification]
        for model in mNotificationArray{
            let notification:MEDUserNotification = model
            if(notification.appid == notificationSetting?.getPacket()){
                let realm = try! Realm()
                try! realm.write {
                    notification.isAddWatch = swicthState.isOn
                }
                addDelegate?.addPacketToWatchDelegate(appid: notification.appid, onOff: swicthState.isOn)
                break
            }
        }
    }
    
}
