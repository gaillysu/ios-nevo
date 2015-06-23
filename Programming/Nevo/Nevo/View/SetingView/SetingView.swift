//
//  SetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetingView: UIView {

    @IBOutlet var tableListView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleBgView: UIView!
    
    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView!
    var mSendLocalNotificationSwitchButton:UISwitch!

    func bulidNotificationViewUI(delegate:ButtonManagerCallBack){
        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("Setting", comment: "")
        title.font = UIFont.systemFontOfSize(25)
        title.textAlignment = NSTextAlignment.Center

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)
        
    }


    @IBAction func buttonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    create the tablecell accrording to nofiticaitonSetting
    
    :param: indexPath  index
    :param: dataSource notification array
    
    :returns: <#return value description#>
    */
    func NotificationlistCell(indexPath:NSIndexPath,dataSource:[NotificationSetting])->UITableViewCell {
        let endCellID:NSString = "SetingCell"
        var endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID as String) as? TableListCell
        var StatesLabel:UILabel!
        
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TableListCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? TableListCell;
            
        }
        endCell?.layer.borderWidth = 0.5;
        endCell?.layer.borderColor = UIColor.grayColor().CGColor;
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.statesSwitch.tag = indexPath.row
        endCell?.statesSwitch.tintColor = AppTheme.NEVO_SOLAR_GRAY()
        endCell?.statesSwitch.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        let setting:NotificationSetting = dataSource[indexPath.row-1]
        if setting.getStates() {
            endCell?.statesSwitch.on = true
            endCell?.round.hidden = false
        }else {
            endCell?.statesSwitch.on = false
            endCell?.round.hidden = true
        }
        endCell?.round.backgroundColor = dataSource[indexPath.row-1].getBagroundColor()
        endCell?.title.text = NSLocalizedString(setting.typeName, comment: "")
        endCell?.round.layer.cornerRadius = 5.0
        endCell?.round.layer.masksToBounds = true

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
        }
        return icon
    }
    
    func NotificationSwicthCell(indexPath:NSIndexPath)->UITableViewCell {
        let endCellID:String = "SwicthCell"
        var endCell:UITableViewCell?
        endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID) as? UITableViewCell
        
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRectMake(0, 0, 50, 40))
            mSendLocalNotificationSwitchButton.center = CGPointMake(endCell!.contentView.frame.size.width-60, 65/2.0)
            mSendLocalNotificationSwitchButton.addTarget(self, action: Selector("SendLocalNotificationSwitchAction:"), forControlEvents: UIControlEvents.ValueChanged)
            mSendLocalNotificationSwitchButton.on = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton.tintColor = AppTheme.NEVO_SOLAR_GRAY()
            mSendLocalNotificationSwitchButton.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            endCell?.contentView.addSubview(mSendLocalNotificationSwitchButton)
            endCell?.layer.borderWidth = 0.5;
            endCell?.layer.borderColor = UIColor.grayColor().CGColor;
            endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
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
