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

    func getNotificationClockCell(indexPath:NSIndexPath, tableView:UITableView, title:String, clockIndex: Int)->UITableViewCell {
        let endCellID:NSString = "NotificationClockCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID as String) as? NotificationClockCell

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NotificationClockCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? NotificationClockCell;
        }
        for view in endCell!.contentView.subviews{
            if(view.isKindOfClass(UIImageView.classForCoder())){
                let clockImage:UIImageView = view as! UIImageView
                clockImage.image = UIImage(named: "\(clockIndex)_clock_dial")
            }
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    func getLineColorCell(indexPath:NSIndexPath,tableView:UITableView,cellTitle:String,clockIndex:Int)->UITableViewCell{
        let endCell:LineColorCell = tableView.dequeueReusableCellWithIdentifier("LineColor_Identifier" ,forIndexPath: indexPath) as! LineColorCell
        endCell.imageName.image = UIImage(named: "notifications_check")
        endCell.imageName.hidden = true
        endCell.imageView?.image = UIImage(named: cellTitle)
        if((clockIndex/2 - 1) == indexPath.row){
            endCell.imageName.hidden = false
        }

        return endCell
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func AllowNotificationsTableViewCell(indexPath:NSIndexPath, tableView:UITableView, title:String, state:Bool)->UITableViewCell {
        let endCellID:String = "AllowNotificationsTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
            let mSwitch:UISwitch = UISwitch(frame: CGRectMake(0,0,51,31))
            mSwitch.on = state
            mSwitch.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSwitch.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSwitch.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-40, (endCell?.contentView.frame.height)!/2)
            endCell?.contentView.addSubview(mSwitch)
        }
        for view in endCell!.contentView.subviews{
            if(view.isKindOfClass(UISwitch.classForCoder())){
                let mSwitch:UISwitch = view as! UISwitch
                mSwitch.on = state
            }
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        return endCell!
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
