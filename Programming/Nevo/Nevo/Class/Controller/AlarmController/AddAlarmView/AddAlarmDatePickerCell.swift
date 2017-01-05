//
//  AddAlarmDatePickerCell.swift
//  Nevo
//
//  Created by Quentin on 5/1/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import SnapKit

class AddAlarmDatePickerCell: UITableViewCell {
    
    var datePicker: UIDatePicker?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 320, height: 235)
        
        let datePicker = UIDatePicker()
        contentView.addSubview(datePicker)
        
        datePicker.snp.makeConstraints { (v) in
            v.top.equalTo(8)
            v.bottom.equalTo(-8)
            v.trailing.equalTo(-8)
            v.leading.equalTo(8)
        }
        
        datePicker.datePickerMode = .time
        
        self.datePicker = datePicker
        
        viewDefaultColorful()
        datePicker.viewDefaultColorful()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func reusableCell(tableView: UITableView, time: TimeInterval) -> AddAlarmDatePickerCell {
        let identifier = "AddAlarmDatePickerCell_ReusableID"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = AddAlarmDatePickerCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell!.selectionStyle = .none
        cell!.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
        
        if time > 0 {
            (cell as! AddAlarmDatePickerCell).datePicker?.date = Date(timeIntervalSince1970: time)
        }
        
        return cell as! AddAlarmDatePickerCell
    }
}
