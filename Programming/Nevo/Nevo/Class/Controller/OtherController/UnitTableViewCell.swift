//
//  UnitTableViewCell.swift
//  Nevo
//
//  Created by Cloud on 2016/12/12.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UnitTableViewCell: UITableViewCell {

    enum TextFieldType {
        case numeric
        case text
        case email
        case date
    }
    
    enum OtherSettingCellType {
        case unit
        case syncTime
    }
    var type: OtherSettingCellType = .unit
    
    @IBOutlet weak var unitSegmented: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitSegmentedField: AutocompleteField!
    weak var picker: UIPickerView?
    
    
    
    let unitArray = [NSLocalizedString("metrics", comment: ""),NSLocalizedString("imperial", comment: "")]
    let timeOptionArray = [NSLocalizedString("home_time", comment: ""), NSLocalizedString("local_time", comment: "")]
    
    var dataArray: [String] {
        switch type {
        case .unit:
            return self.unitArray
        case .syncTime:
            return self.timeOptionArray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unitSegmented.backgroundColor = UIColor.clear
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        
        unitSegmentedField.textColor = UIColor.white
        unitSegmentedField.delegate = self
        
        let picker = UIPickerView()
        picker.delegate = self;
        picker.dataSource = self;
        self.picker = picker
        
        unitSegmentedField.inputView = picker;
        unitSegmentedField.backgroundColor = UIColor.clear
        unitSegmentedField.tintColor = UIColor.clear
    }
}

// MARK: - Mainly API
extension UnitTableViewCell {
    class func getCell(with tableView: UITableView, type: OtherSettingCellType) -> UnitTableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "") as? UnitTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "unit_identifier")
            cell = tableView.dequeueReusableCell(withIdentifier: "unit_identifier") as? UnitTableViewCell
            
            cell?.type = type
        }
        
        switch type {
        case .unit:
            if let value = MEDSettings.int(forKey: "UserSelectedUnit") {
                cell?.unitSegmentedField.text = cell?.unitArray[value]
                cell?.picker?.selectRow(value, inComponent: 0, animated: false)
            }else{
                cell?.unitSegmentedField.text = cell?.unitArray[0]
            }
            
        case .syncTime:
            /// TODO: 同步时间 cell 的默认行为
            cell?.unitSegmentedField.text = cell?.timeOptionArray[0]
            cell?.picker?.selectedRow(inComponent: 0)
            break
        }
        
        return cell!
    }
}

// MARK: - UITextFieldDelegate
extension UnitTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - UIPickerViewDataSource
extension UnitTableViewCell: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row]
    }
}

// MARK: - UIPickerViewDelegate
extension UnitTableViewCell: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitSegmentedField.text = dataArray[row]
        
        switch type {
        case .unit:
            MEDSettings.setValue(row, forKey: "UserSelectedUnit")
        case .syncTime:
            // TODO: 同步时间选择后要做的事
            //0->home_time ,1->local_time
            MEDSettings.setValue(row, forKey: "SET_SYNCTIME_TYPE")
            if AppDelegate.getAppDelegate().isConnected(), let date:Date = HomeClockUtil.shared.getHomeTime(){
                let offset = fabs(Date().timeIntervalSince1970-date.timeIntervalSince1970)/3600
                let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: offset.toInt())
                AppDelegate.getAppDelegate().sendRequest(setWordClock)
            }else{
                let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: 0)
                AppDelegate.getAppDelegate().sendRequest(setWordClock)
            }
            break
        }
    }
}
