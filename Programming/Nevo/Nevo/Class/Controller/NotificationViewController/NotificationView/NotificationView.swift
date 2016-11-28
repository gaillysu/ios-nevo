//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Kingfisher

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

        endCell.setTitleLabel(title: NSLocalizedString(steting.getAppName(), comment: ""))
        endCell.setContentLabel(content: NSLocalizedString(detailLabel, comment: ""))

        endCell.setTitleImage(imageName: "new_\(title.lowercased())")
        
        if endCell.titleImage.image == nil {
            endCell.setTitleLabel(title: "loading...")
            endCell.setTitleImage(imageName: "AppIcon")
            
            MEDAppInfoRequester.requesAppInfoWith(bundleId: steting.getPacket(), resultHandle: {
                (error, appInfo) in
                
                if let info = appInfo {
                    endCell.setTitleLabel(title: info.trackName)
                    endCell.titleImage.kf.setImage(with: URL(string: info.artworkUrl100), placeholder: UIImage(named:"AppIcon"), options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    #if DEBUG
                        fatalError("\(error)")
                    #else
                        print("\(error)")
                    #endif
                }
            })
        }
        
        
        endCell.setContentLabel(content: NSLocalizedString(detailLabel, comment: ""))
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
