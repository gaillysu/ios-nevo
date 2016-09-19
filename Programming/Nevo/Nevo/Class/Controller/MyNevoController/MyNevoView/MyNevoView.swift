//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UITableView {

    class func getMyNevoViewTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,detailText:String)->UITableViewCell {
        let endCellID:String = "getMyNevoViewTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: endCellID)
        }
//        if(indexPath.row == 0) {
//            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        }else{
//
//        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        endCell?.textLabel?.text = title
        endCell?.detailTextLabel?.text = detailText
        return endCell!
    }
}
