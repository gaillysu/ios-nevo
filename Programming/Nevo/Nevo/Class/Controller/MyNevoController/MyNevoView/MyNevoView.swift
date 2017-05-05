//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UITableView {

    class func getMyNevoViewTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,detailText:String,isUpdate:Bool)->UITableViewCell {
        let endCellID:String = "getMyNevoViewTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: endCellID)
        }
        if(indexPath.row == 0 && isUpdate) {
            endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }else{
            endCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        endCell?.textLabel?.backgroundColor = UIColor.clear
        endCell?.textLabel?.text = title
        endCell?.detailTextLabel?.backgroundColor = UIColor.clear
        endCell?.detailTextLabel?.text = detailText
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            endCell?.backgroundColor = UIColor.getGreyColor()
            endCell?.textLabel?.textColor = UIColor.white
            endCell?.detailTextLabel?.textColor = UIColor.white
        }
        return endCell!
    }
}
