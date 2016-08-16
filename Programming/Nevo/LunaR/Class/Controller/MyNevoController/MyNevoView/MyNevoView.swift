//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UITableView {

    class func getMyNevoViewTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String,detailText:String)->UITableViewCell {
        let endCellID:String = "getMyNevoViewTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: endCellID)
        }
        if(indexPath.row == 0) {
            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else{

        }
        endCell?.layoutMargins = UIEdgeInsetsZero
        endCell?.separatorInset = UIEdgeInsetsZero
        endCell?.backgroundColor = UIColor.getGreyColor()
        endCell?.contentView.backgroundColor = UIColor.getGreyColor()
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        endCell?.textLabel?.textColor = UIColor.whiteColor()
        endCell?.detailTextLabel?.text = detailText
        return endCell!
    }
}
