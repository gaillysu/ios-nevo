//
//  UserProfileCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField

class UserProfileCell: UITableViewCell,UIPickerViewDelegate,UIPickerViewDataSource {
    enum Type{
        case Numeric
        case Text
        case Email
        case Date
    }
    
    private var keyBoardType:Type?{
        didSet {
            if keyBoardType == Type.Email {
                
            }
        }
    }
    private var inputVariables: NSMutableArray = NSMutableArray()
    var textPreFix = "";
    var textPostFix = "";
    var cellIndex:Int = 0
    var editCellTextField:((index:Int, text:String) -> Void)?
    
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: AutocompleteField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateLabel(labelText: String){
        let contentDict:[String:AnyObject] = [NSFontAttributeName:titleLabel.font]
        titleLabel.text = labelText
        let statusLabelSize = labelText.sizeWithAttributes(contentDict)
        labelWidthConstraint.constant = statusLabelSize.width + 5
        layoutIfNeeded()
    }
    
    func setInputVariables(vars:NSMutableArray){
        self.inputVariables = vars
    }
    
    func setType(type:Type){
        keyBoardType = type
        if type == Type.Email {
            valueTextField.keyboardType = UIKeyboardType.EmailAddress
        }else if type == Type.Numeric {
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            valueTextField.inputView = picker;
        }else if type == Type.Date {
            let datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.Date
            valueTextField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }else{
            valueTextField.keyboardType = UIKeyboardType.Default
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if keyBoardType == Type.Date {
            editCellTextField?(index: cellIndex,text: textField.text!.componentsSeparatedByString(" ")[1])
        }else{
            editCellTextField?(index: cellIndex,text: textField.text!)
        }
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return inputVariables.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(inputVariables[row])"+"\(textPostFix)"
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueTextField.text = "\(textPreFix)"+"\(inputVariables[row])"+"\(textPostFix)"
        editCellTextField?(index: cellIndex,text: "\(inputVariables[row])")
    }
    
    func selectedDateAction(date:UIDatePicker) {
        NSLog("date:\(date.date)")
        valueTextField.text = "\(textPreFix)"+self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date)
        editCellTextField?(index: cellIndex,text: self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date))
    }
    
    func dateFormattedStringWithFormat(format: String, fromDate date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
}
