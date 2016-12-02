//
//  UserProfileCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit


class UserProfileCell: UITableViewCell {
    enum `Type`{
        case numeric
        case text
        case email
        case date
    }
    
    fileprivate var keyBoardType:Type?{
        didSet {
            if keyBoardType == Type.email {
            }
        }
    }
    fileprivate var inputVariables: NSMutableArray = NSMutableArray()
    var textPreFix = "";
    var textPostFix = "";
    var cellIndex:Int = 0
    var editCellTextField:((_ index:Int, _ text:String) -> Void)?
    
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: AutocompleteField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueTextField.delegate = self
        
        /// APPTHEME ADJUST
        viewDefaultColorful()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            titleLabel.textColor = UIColor.white
            valueTextField.textColor = UIColor.getBaseColor()
        }
    }

    func updateLabel(_ labelText: String){
        let contentDict:[String:AnyObject] = [NSFontAttributeName:titleLabel.font]
        titleLabel.text = labelText
        let statusLabelSize = labelText.size(attributes: contentDict)
        labelWidthConstraint.constant = statusLabelSize.width + 5
        layoutIfNeeded()
    }
    
    func setInputVariables(_ vars:NSMutableArray){
        self.inputVariables = vars
    }
    
    func setType(_ type:Type){
        keyBoardType = type
        if type == Type.email {
            valueTextField.keyboardType = UIKeyboardType.emailAddress
        }else if type == Type.numeric {
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            valueTextField.inputView = picker;
        }else if type == Type.date {
            let datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.date
            valueTextField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), for: UIControlEvents.valueChanged)
        }else{
            valueTextField.keyboardType = UIKeyboardType.default
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension UserProfileCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if keyBoardType == Type.date {
            editCellTextField?(cellIndex,textField.text!.components(separatedBy: " ")[1])
        }else{
            editCellTextField?(cellIndex,textField.text!)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - UIPickerViewDataSource
extension UserProfileCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? inputVariables.count : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(inputVariables[row])"
        } else {
            return "\(textPostFix)"
        }
    }
    
}

// MARK: - UIPickerViewDelegate
extension UserProfileCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueTextField.text = "\(textPreFix)"+"\(inputVariables[row])"+"\(textPostFix)"
        editCellTextField?(cellIndex,"\(inputVariables[row])")
    }
}

// MARK: - Private function
extension UserProfileCell {
    func selectedDateAction(_ date:UIDatePicker) {
        NSLog("date:\(date.date)")
        
        var dateFormatStr = ""
        let languages = NSLocale.preferredLanguages
        if let currentLang = languages.first {
            let langsArray = ["zh", "zh-Hans", "zh-Hant", "zh-Hans-CN", "zh-Hant-CN"]
            if langsArray.contains(currentLang) {
                dateFormatStr = "yyyy-MM-dd"
            } else {
                dateFormatStr = "dd-MM-yyyy"
            }
        }
        valueTextField.text = "\(textPreFix)"+self.dateFormattedStringWithFormat(dateFormatStr, fromDate: date.date)
        editCellTextField?(cellIndex,self.dateFormattedStringWithFormat(dateFormatStr, fromDate: date.date))
    }
    
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
