//
//  SelectedNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import SnapKit

class SelectedNotificationView: UITableView {

    func bulidSelectedNotificationView(_ navigationItem:UINavigationItem){
        
    }

    func getNotificationClockCell(_ indexPath:IndexPath, tableView:UITableView, image:UIImage?, clockIndex: Int)->UITableViewCell {
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
        endCell.imageView?.image = UIImage(named: cellTitle)
        if((clockIndex/2 - 1) == indexPath.row){
            let image = UIImage(named: "notifications_check")
            endCell.accessoryView = UIImageView(image: image)
        }else{
            endCell.accessoryView = nil;
        }
        
        endCell.textLabel!.text = cellTitle;
        return endCell
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func allowNotificationsTableViewCell(_ indexPath:IndexPath, tableView:UITableView, title:String, setting:NotificationSetting)->UITableViewCell {
        let allowCell:AllowNotificationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AllowNotifications_Identifier", for: indexPath) as! AllowNotificationsTableViewCell
        allowCell.selectionStyle = UITableViewCellSelectionStyle.none;
        let titleColor:UIColor = UIColor.black
        let onColor:UIColor = AppTheme.NEVO_SOLAR_YELLOW()
        allowCell.setAllowSwitch(color: onColor,isOn:setting.getStates())
        allowCell.setTitleLabel(title: title, titleColor: titleColor, titleFont: nil)

        return allowCell
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
