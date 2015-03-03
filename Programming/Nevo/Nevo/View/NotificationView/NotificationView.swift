//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet var tableListView: UITableView!

    func NotificationlistCell(indexPath:NSIndexPath,dataSource:NSArray)->UITableViewCell {
        let endCellID:NSString = "endCell"
        var endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID) as? UITableViewCell
        var StatesLabel:UILabel!

        if (endCell == nil) {
            endCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier: endCellID)
            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            StatesLabel = UILabel(frame: CGRectMake(0, 0, 55, 30))
            //StatesLabel.center = CGPointMake(endCell?.frame.size.height/2.0, endCell?.frame.size.height/2.0)
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.backgroundColor = UIColor.whiteColor();
        endCell?.textLabel?.text = dataSource[indexPath.row] as? String
        endCell?.detailTextLabel?.text = "FFFF"

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
