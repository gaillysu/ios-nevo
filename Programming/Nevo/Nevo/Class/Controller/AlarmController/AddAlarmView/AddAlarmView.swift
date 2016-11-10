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
    class func addAlarmTimerTableViewCell(_ indexPath:IndexPath,tableView:UITableView,timer:TimeInterval)->UITableViewCell {
        let endCell:AddAlarmTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddAlarm_Date_identifier", for: indexPath) as! AddAlarmTableViewCell
        endCell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
        endCell.selectionStyle = UITableViewCellSelectionStyle.none;
        endCell.backgroundColor = UIColor.clear
        endCell.contentView.backgroundColor = UIColor.clear
        if(timer > 0){
            endCell.datePicker.date = Date(timeIntervalSince1970: timer)
            endCell.datePicker.backgroundColor = UIColor.white
        }
        return endCell
    }

    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    class func systemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,delegate:ButtonManagerCallBack)->UITableViewCell {
        let endCellID:String = "SystemCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            let nibs:[Any] = Bundle.main.loadNibNamed("AddAlarmSystemCell", owner: self, options: nil)!
            endCell = nibs[0] as? AddAlarmSystemCell;
        }
        (endCell as! AddAlarmSystemCell).mDelegate = delegate
        if(title == "Repeat"){

        }

        if(title == "Label"){
            (endCell as! AddAlarmSystemCell).repeatSwicth.isHidden = true
            //(endCell as! AddAlarmSystemCell).repeatSwicth.removeFromSuperview()
            endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }

        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        (endCell as! AddAlarmSystemCell).systemTitle.text = NSLocalizedString("\(title)", comment: "")
        return endCell!
    }

    func bulidAdTableView(_ navigation:UINavigationItem){
        
    }

    func buttonManage(_ sender:AnyObject){
        NSLog("------------")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
