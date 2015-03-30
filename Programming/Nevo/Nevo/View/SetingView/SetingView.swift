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
    
    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView!

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
        let endCellID:NSString = "endCell"
        var endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID) as? TableListCell
        var StatesLabel:UILabel!
        
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TableListCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? TableListCell;
            //endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            
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
        }else {
            endCell?.statesSwitch.on = false
        }
        endCell?.textLabel?.text = NSLocalizedString(setting.typeName, comment: "")
        endCell?.imageView?.image = UIImage(named:SetingView.getNotificationSettingIcon(setting))

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
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
