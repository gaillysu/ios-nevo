//
//  AddAlarmCell.swift
//  Nevo
//
//  Created by Quentin on 5/1/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit


class AddAlarmCell: UITableViewCell {
    
    lazy var repeatSwitch: UISwitch = {
        return UISwitch()
    }()
    
    class func reusableCell(tableView: UITableView, title: String) -> AddAlarmCell {
        let reusableID = "AddAlarmCell_ReusableID"
        var cell = tableView.dequeueReusableCell(withIdentifier: reusableID)
        
        if cell == nil {
            cell = AddAlarmCell(style: .value1, reuseIdentifier: reusableID)
        }
        
        let addAlarmCell = cell as! AddAlarmCell
        
        addAlarmCell.textLabel?.text = NSLocalizedString(title, comment: "")
        addAlarmCell.textLabel?.font = UIFont(name: "Raleway", size: 16)
        
        if title == "Repeat" {
            addAlarmCell.accessoryType = .none
            addAlarmCell.accessoryView = addAlarmCell.repeatSwitch
        } else {
            addAlarmCell.accessoryType = .disclosureIndicator
            addAlarmCell.accessoryView = nil
        }
        
        addAlarmCell.selectionStyle = .none
        
        addAlarmCell.viewDefaultColorful()
        addAlarmCell.repeatSwitch.viewDefaultColorful()
        
        return addAlarmCell
    }
    
    class func reusableCellForNewAlarm(tableView: UITableView, title: String) -> AddAlarmCell {
        let reusableID = "AddAlarmCell_ReusableID"
        var cell = tableView.dequeueReusableCell(withIdentifier: reusableID)
        
        if cell == nil {
            cell = AddAlarmCell(style: .value1, reuseIdentifier: reusableID)
        }
        
        cell?.textLabel?.font = UIFont(name: "Raleway", size: 16)
        cell?.textLabel?.text = NSLocalizedString(title, comment: "")
        
        cell?.accessoryType = .disclosureIndicator
        
        cell?.selectionStyle = .none
        
        cell?.viewDefaultColorful()
        
        return cell as! AddAlarmCell
    }
}
