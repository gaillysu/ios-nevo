//
//  UnitTableViewCell.swift
//  Nevo
//
//  Created by Cloud on 2016/12/12.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UnitTableViewCell: UITableViewCell,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {

    enum TextFieldType {
        case numeric
        case text
        case email
        case date
    }
    
    @IBOutlet weak var unitSegmented: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitSegmentedField: AutocompleteField!

    
    let unitArray:[String] = [NSLocalizedString("metrics", comment: ""),NSLocalizedString("imperial", comment: "")]
    
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
        
        unitSegmentedField.inputView = picker;
        unitSegmentedField.backgroundColor = UIColor.clear
        if let value = UserDefaults.standard.object(forKey: "UserSelectedUnit") {
            let index:Int = value as! Int
            unitSegmentedField.text = unitArray[index]
            picker.selectRow(index, inComponent: 0, animated: false)
        }else{
            unitSegmentedField.text = unitArray[0]
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitArray[row]
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitSegmentedField.text = unitArray[row]
        let userDefault:UserDefaults = UserDefaults.standard
        userDefault.set(row, forKey: "UserSelectedUnit")
        userDefault.synchronize()
    }
    
}
