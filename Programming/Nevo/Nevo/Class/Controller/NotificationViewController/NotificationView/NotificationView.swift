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
    class func NotificationSystemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,detailLabel:String,steting:NotificationSetting)->UITableViewCell {
        let endCell:NotificationTypeCell = tableView.dequeueReusableCell(withIdentifier: "Notification_Identifier", for: indexPath) as! NotificationTypeCell
        endCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        endCell.setTitleLabel(title: NSLocalizedString(title, comment: ""))
        endCell.setContentLabel(content: NSLocalizedString(detailLabel, comment: ""))
        endCell.setTitleImage(imageName: "new_\(title.lowercased())")
        endCell.setSwitchState(steting.getStates())
        endCell.notificationSetting = steting
        return endCell
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
