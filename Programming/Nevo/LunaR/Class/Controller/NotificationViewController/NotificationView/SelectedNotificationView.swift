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
        let endCellID:String = "NotificationClock_ReuseIdentifier"
        let endCell = tableView.dequeueReusableCellWithIdentifier(endCellID,forIndexPath:indexPath)
        endCell.backgroundColor = UIColor.getGreyColor()
        endCell.contentView.backgroundColor = UIColor.getGreyColor()
        for view in endCell.contentView.subviews{
            if(view.isKindOfClass(UIImageView.classForCoder())){
                let clockImage:UIImageView = view as! UIImageView
                clockImage.image = AppTheme.GET_RESOURCES_IMAGE("notification_background")
            }
        }
        endCell.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell
    }

    func getLineColorCell(indexPath:NSIndexPath,tableView:UITableView,cellTitle:String,clockIndex:Int)->UITableViewCell{
        let endCellID:String = "LineColorCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)

        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
            let selectedView:UIImageView = UIImageView(frame: CGRectMake(0, 0, endCell!.frame.size.height - 25, endCell!.frame.size.height - 25))
            selectedView.backgroundColor = UIColor.clearColor()
            selectedView.image = UIImage(named: "notifications_selected_background")
            selectedView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-(endCell!.frame.size.height - 25), endCell!.frame.size.height/2.0)
            selectedView.tag = checkTag
            selectedView.hidden = true
            endCell?.contentView.addSubview(selectedView)
        }
        if((clockIndex/2 - 1) == indexPath.row){
            let checkView = endCell?.contentView.viewWithTag(checkTag)
            if(checkView != nil){
                checkView?.hidden = false
            }
        }

        //endCell?.selectionStyle = UITableViewCellSelectionStyle.Blue;
        //endCell?.textLabel?.text = cellTitle
        endCell?.imageView?.image = UIImage(named: cellTitle)
        return endCell!
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
            mSwitch.tintColor = UIColor.getBaseColor()
            mSwitch.onTintColor = UIColor.getBaseColor()
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
        endCell?.textLabel?.textColor = UIColor.whiteColor()
        endCell?.backgroundColor = UIColor.getGreyColor()
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
