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
        var endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID) as? TableListCell
        var StatesLabel:UILabel!

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TableListCell", owner: self, options: nil)
             endCell = nibs.objectAtIndex(0) as? TableListCell;
            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            endCell?.backgroundColor = UIColor.clearColor();

        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.imageView?.image = UIImage(named:dataSource[indexPath.row].objectAtIndex(1) as String)
        endCell?.textLabel?.text = dataSource[indexPath.row].objectAtIndex(0) as? String
        endCell?.StatesLabel.textColor = AppTheme.NEVO_SOLAR_GRAY()
        endCell?.StatesLabel.text = "On"

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
