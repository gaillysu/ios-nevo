//
//  SelectedNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SelectedNotificationView: UITableView {

    func bulidSelectedNotificationView(navigationItem:UINavigationItem){

        
    }

    func getNotificationClockCell(indexPath:NSIndexPath,tableView:UITableView,title:String)->UITableViewCell {
        let endCellID:NSString = "NotificationClockCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID as String) as? NotificationClockCell

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NotificationClockCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? NotificationClockCell;
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    func getLineColorCell(indexPath:NSIndexPath,tableView:UITableView,title:String)->UITableViewCell{
        let endCellID:NSString = "LineColorCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID as String) as? LineColorCell

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("LineColorCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? LineColorCell;
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func AllowNotificationsTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String)->UITableViewCell {
        let endCellID:String = "AllowNotificationsTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
        }
        let mSwitch:UISwitch = UISwitch(frame: CGRectMake(0,0,51,31))
        mSwitch.on = ConnectionManager.sharedInstance.getIsSendLocalMsg()
        mSwitch.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        mSwitch.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        mSwitch.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.ValueChanged)
        mSwitch.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-40, (endCell?.contentView.frame.height)!/2)
        endCell?.contentView.addSubview(mSwitch)

        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        return endCell!
    }

    func buttonAction(sender:AnyObject){

    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
