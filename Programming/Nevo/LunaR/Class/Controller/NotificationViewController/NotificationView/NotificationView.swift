//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationView: UITableView {

    func bulidNotificationView(navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Notifications", comment: "")
    }

    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    class func NotificationSystemTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String,detailLabel:String)->UITableViewCell {
        let endCellID:String = "NotificationSystemTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = NSLocalizedString(title, comment: "")

        endCell?.detailTextLabel?.text = NSLocalizedString(detailLabel, comment: "")
        endCell?.detailTextLabel?.font = AppTheme.FONT_SFCOMPACTDISPLAY_LIGHT(mSize: 13)
        endCell?.imageView?.image = UIImage(named: "new_\(title.lowercaseString)")
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
