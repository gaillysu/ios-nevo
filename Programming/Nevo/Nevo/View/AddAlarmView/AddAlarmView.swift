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
     returns the time zone TableViewCell selector

     :param: indexPath TableView path
     :param: tableView TableView Object

     :returns: time zone TableViewCell selector
     */
    class func addAlarmTimerTableViewCell(indexPath:NSIndexPath,tableView:UITableView)->UITableViewCell {
        let endCellID:String = "AddAlarmCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("AddAlarmTableViewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? AddAlarmTableViewCell;

        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    class func systemTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String)->UITableViewCell {
        let endCellID:String = "SystemCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
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
