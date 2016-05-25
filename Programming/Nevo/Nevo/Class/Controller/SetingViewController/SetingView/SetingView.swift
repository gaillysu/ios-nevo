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
    
    private var mDelegate:ButtonManagerCallBack?
    //var animationView:AnimationView!
    var mSendLocalNotificationSwitchButton:UISwitch!

    func bulidNotificationViewUI(delegate:ButtonManagerCallBack){
        //title.text = NSLocalizedString("Setting", comment: "")
        mDelegate = delegate
        
    }


    @IBAction func buttonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }
    
    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    func NotificationSystemTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String,imageName:String)->UITableViewCell {
        let endCellID:String = "NotificationSystemTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
        }
        if(title == NSLocalizedString("find_my_watch", comment: "") || title == NSLocalizedString("forget_watch", comment: "")) {
            let activity:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activity.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-activity.frame.size.width, 50/2.0)
            endCell?.contentView.addSubview(activity)
        }else{
            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        endCell?.textLabel?.text = title
        endCell?.imageView?.image = UIImage(named: imageName)
        return endCell!
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func LinkLossNotificationsTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String ,imageName:String)->UITableViewCell {
        let endCellID:String = "LinkLossNotificationsTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
        }
        
        let view = endCell!.contentView.viewWithTag(NotificationSwitchButtonTAG)
        if view == nil {
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRectMake(0,0,51,31))
            mSendLocalNotificationSwitchButton.tag = NotificationSwitchButtonTAG
            mSendLocalNotificationSwitchButton?.on = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton?.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSendLocalNotificationSwitchButton?.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSendLocalNotificationSwitchButton?.addTarget(self, action: #selector(SetingView.buttonAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
            mSendLocalNotificationSwitchButton?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-40, 50.0/2.0)
            endCell?.contentView.addSubview(mSendLocalNotificationSwitchButton!)
        }
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.imageView?.image = UIImage(named: imageName)
        endCell?.textLabel?.text = title
        return endCell!
    }

    /**
    get the icon according to the notificationSetting
    
    :param: notificationSetting NotificationSetting
    
    :returns: return the icon
    */
    class func getNotificationSettingIcon(notificationSetting:NotificationSetting) -> String {
        var icon:String = ""
        switch notificationSetting.getType() {
        case .CALL:
            icon = "callIcon"
        case .EMAIL:
            icon = "emailIcon"
        case .FACEBOOK:
            icon = "facebookIcon"
        case .SMS:
            icon = "smsIcon"
        case .CALENDAR:
            icon = "calendar_icon"
        case .WECHAT:
            icon = "WeChat_Icon"
        case .WHATSAPP:
            icon = "WeChat_Icon"
        }
        return icon
    }
    
    func NotificationSwicthCell(indexPath:NSIndexPath)->UITableViewCell {
        let endCellID:String = "SwicthCell"
        var endCell:UITableViewCell?
        endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRectMake(0, 0, 50, 40))
            mSendLocalNotificationSwitchButton.center = CGPointMake(endCell!.contentView.frame.size.width-60, 65/2.0)
            mSendLocalNotificationSwitchButton.addTarget(self, action: #selector(SetingView.SendLocalNotificationSwitchAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
            mSendLocalNotificationSwitchButton.on = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton.tintColor = AppTheme.NEVO_SOLAR_GRAY()
            mSendLocalNotificationSwitchButton.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            endCell?.contentView.addSubview(mSendLocalNotificationSwitchButton)
            endCell?.layer.borderWidth = 0.5;
            endCell?.layer.borderColor = UIColor.grayColor().CGColor;
            //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
            endCell?.textLabel?.text = NSLocalizedString("Link-Loss Notifications", comment: "")
        }
        return endCell!
    }
    
    func SendLocalNotificationSwitchAction(swicth:UISwitch) {
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
