//
//  SelectedNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SelectedNotificationView: UITableView {

    func bulidSelectedNotificationView(_ navigationItem:UINavigationItem){
        
    }

    func getNotificationClockCell(_ indexPath:IndexPath, tableView:UITableView, title:String, clockIndex: Int)->UITableViewCell {
        let endCellID:NSString = "NotificationClockCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID as String) as? NotificationClockCell

        if (endCell == nil) {
            let nibs:[Any] = Bundle.main.loadNibNamed("NotificationClockCell", owner: self, options: nil)!
            endCell = nibs[0] as? NotificationClockCell;
        }
        for view in endCell!.contentView.subviews{
            if(view.isKind(of: UIImageView.classForCoder())){
                let clockImage:UIImageView = view as! UIImageView
                clockImage.image = UIImage(named: "\(clockIndex)_clock_dial")
            }
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        return endCell!
    }

    func getLineColorCell(_ indexPath:IndexPath,tableView:UITableView,cellTitle:String,clockIndex:Int)->UITableViewCell{
        let endCell:LineColorCell = tableView.dequeueReusableCell(withIdentifier: "LineColor_Identifier" ,for: indexPath) as! LineColorCell
        endCell.imageName.image = UIImage(named: "notifications_check")
        endCell.imageName.isHidden = true
        endCell.imageView?.image = UIImage(named: cellTitle)
        if((clockIndex/2 - 1) == (indexPath as NSIndexPath).row){
            endCell.imageName.isHidden = false
        }
        
        endCell.textLabel!.text = cellTitle
        endCell.textLabel!.backgroundColor = UIColor.clear
        
        return endCell
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func AllowNotificationsTableViewCell(_ indexPath:IndexPath, tableView:UITableView, title:String, state:Bool)->UITableViewCell {
        let endCellID:String = "AllowNotificationsTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: endCellID)
            let mSwitch:UISwitch = UISwitch(frame: CGRect(x: 0,y: 0,width: 51,height: 31))
            mSwitch.isOn = state
            mSwitch.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSwitch.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSwitch.center = CGPoint(x: UIScreen.main.bounds.size.width-40, y: (endCell?.contentView.frame.height)!/2)
            endCell?.contentView.addSubview(mSwitch)
        }
        for view in endCell!.contentView.subviews{
            if(view.isKind(of: UISwitch.classForCoder())){
                let mSwitch:UISwitch = view as! UISwitch
                mSwitch.isOn = state
            }
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
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
