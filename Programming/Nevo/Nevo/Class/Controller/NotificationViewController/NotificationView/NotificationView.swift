//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationView: UITableView {

    func bulidNotificationView(_ navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Notifications", comment: "")
    }

    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    class func NotificationSystemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,detailLabel:String)->UITableViewCell {
        let endCellID:String = "NotificationSystemTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = NSLocalizedString(title, comment: "")

        endCell?.detailTextLabel?.text = NSLocalizedString(detailLabel, comment: "")
        endCell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        endCell?.imageView?.image = UIImage(named: "new_\(title.lowercased())")
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            endCell?.backgroundColor = UIColor.getGreyColor()
            endCell?.textLabel?.textColor = UIColor.white
            endCell?.detailTextLabel?.textColor = UIColor.white
        }
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
