//
//  AddAlarmView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddAlarmView: UITableView {

    /**
     create the tablecell accrording to nofiticaitonSetting

     :param: indexPath  index
     :param: dataSource notification array

     :returns: <#return value description#>
     */
    class func addAlarmTimerTableViewCell(indexPath:NSIndexPath,tableView:UITableView)->UITableViewCell {
        let endCellID:String = "AddAlarmCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("AddAlarmTableViewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? AddAlarmTableViewCell;

        }
        endCell?.layer.borderWidth = 0.5;
        endCell?.layer.borderColor = UIColor.grayColor().CGColor;
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    func bulidAdTableView(navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Add Alarm", comment: "")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
