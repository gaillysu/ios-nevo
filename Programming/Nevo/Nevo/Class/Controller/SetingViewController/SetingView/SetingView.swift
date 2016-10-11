//
//  SetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

private let NotificationSwitchButtonTAG:Int = 1690
class SetingView: UIView {

    @IBOutlet var tableListView: UITableView!
    
    fileprivate var mDelegate:ButtonManagerCallBack?
    //var animationView:AnimationView!
    var mSendLocalNotificationSwitchButton:UISwitch!

    func bulidNotificationViewUI(_ delegate:ButtonManagerCallBack){
        //title.text = NSLocalizedString("Setting", comment: "")
        mDelegate = delegate
        //tableListView.backgroundColor = UIColor.white
        tableListView.separatorColor = UIColor.lightGray
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tableListView.backgroundColor = UIColor.getLightBaseColor()
            tableListView.separatorColor = UIColor.getLightBaseColor()
        }
    }


    @IBAction func buttonAction(_ sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }
    
    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    func NotificationSystemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,imageName:String)->UITableViewCell {
        let endCellID:String = "NotificationSystemTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: endCellID)
        }
        endCell?.backgroundColor = UIColor.white
        if(title == NSLocalizedString("find_my_watch", comment: "") || title == NSLocalizedString("forget_watch", comment: "")) {
            let activity:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activity.center = CGPoint(x: UIScreen.main.bounds.size.width-activity.frame.size.width, y: 50/2.0)
            endCell?.contentView.addSubview(activity)
        }else{
            endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        endCell?.textLabel?.text = title
        endCell?.textLabel?.textColor = UIColor.black
        endCell?.textLabel!.backgroundColor = UIColor.clear
        endCell?.imageView?.image = UIImage(named: imageName)
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            endCell?.backgroundColor = UIColor.getGreyColor()
            mSendLocalNotificationSwitchButton?.onTintColor = UIColor.getBaseColor()
            endCell?.textLabel?.textColor = UIColor.white
        }
        
        return endCell!
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func LinkLossNotificationsTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String ,imageName:String)->UITableViewCell {
        let endCellID:String = "LinkLossNotificationsTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: endCellID)
        }
        endCell?.backgroundColor = UIColor.white
        endCell?.contentView.backgroundColor = UIColor.white
        endCell?.imageView?.image = UIImage(named: imageName)
        endCell?.textLabel?.text = title
        endCell?.textLabel?.textColor = UIColor.black
        
        let view = endCell!.contentView.viewWithTag(NotificationSwitchButtonTAG)
        if view == nil {
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRect(x: 0,y: 0,width: 51,height: 31))
            mSendLocalNotificationSwitchButton.tag = NotificationSwitchButtonTAG
            mSendLocalNotificationSwitchButton?.isOn = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton?.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSendLocalNotificationSwitchButton?.addTarget(self, action: #selector(SetingView.buttonAction(_:)), for: UIControlEvents.valueChanged)
            mSendLocalNotificationSwitchButton?.center = CGPoint(x: UIScreen.main.bounds.size.width-40, y: 50.0/2.0)
            endCell?.contentView.addSubview(mSendLocalNotificationSwitchButton!)
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            endCell?.backgroundColor = UIColor.getGreyColor()
            endCell?.contentView.backgroundColor = UIColor.getGreyColor()
            mSendLocalNotificationSwitchButton?.onTintColor = UIColor.getBaseColor()
            endCell?.textLabel?.textColor = UIColor.white
        }
        return endCell!
    }

    /**
    get the icon according to the notificationSetting
    
    :param: notificationSetting NotificationSetting
    
    :returns: return the icon
    */
    class func getNotificationSettingIcon(_ notificationSetting:NotificationSetting) -> String {
        var icon:String = ""
        switch notificationSetting.getType() {
        case .call:
            icon = "callIcon"
        case .email:
            icon = "emailIcon"
        case .facebook:
            icon = "facebookIcon"
        case .sms:
            icon = "smsIcon"
        case .calendar:
            icon = "calendar_icon"
        case .wechat:
            icon = "WeChat_Icon"
        case .whatsapp:
            icon = "WeChat_Icon"
        }
        return icon
    }
    
    func NotificationSwicthCell(_ indexPath:IndexPath)->UITableViewCell {
        let endCellID:String = "SwicthCell"
        var endCell:UITableViewCell?
        endCell = tableListView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: endCellID)
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            mSendLocalNotificationSwitchButton.center = CGPoint(x: endCell!.contentView.frame.size.width-60, y: 65/2.0)
            mSendLocalNotificationSwitchButton.addTarget(self, action: #selector(SetingView.SendLocalNotificationSwitchAction(_:)), for: UIControlEvents.valueChanged)
            mSendLocalNotificationSwitchButton.isOn = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton.tintColor = AppTheme.NEVO_SOLAR_GRAY()
            mSendLocalNotificationSwitchButton.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            endCell?.contentView.addSubview(mSendLocalNotificationSwitchButton)
            endCell?.layer.borderWidth = 0.5;
            endCell?.layer.borderColor = UIColor.gray.cgColor;
            //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
            endCell?.textLabel?.text = NSLocalizedString("Link-Loss Notifications", comment: "")
        }
        return endCell!
    }
    
    func SendLocalNotificationSwitchAction(_ swicth:UISwitch) {
        mDelegate?.controllManager(swicth)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
