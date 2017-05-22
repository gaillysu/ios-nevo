//
//  DatePickerView.swift
//  Nevo
//
//  Created by leiyuncun on 16/1/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

protocol DatePickerViewDelegate:NSObjectProtocol {
    /**
    *  选择日期确定后的代理事件
    *
    *  @param date 日期
    *  @param type 时间选择器状态
    */
    func getSelectDate(_ index:Int,date:NSArray)
}

class DatePickerView: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var endDatePicker: UIPickerView!
    @IBOutlet weak var weekDatePicker: UIPickerView!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var delegate:DatePickerViewDelegate?

    fileprivate var startDate:NSMutableArray = NSMutableArray(array: [0,0])
    fileprivate var endDate:NSMutableArray =  NSMutableArray(array: [0,0])
    fileprivate var week:NSMutableArray = NSMutableArray(array: [0])

    var index:Int = 0

    var selectDate:NSMutableArray = NSMutableArray()

    let weekArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    init() {
        super.init(nibName: "DatePickerView", bundle: Bundle.main)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectDate.insert(startDate, at: 0)
        selectDate.insert(endDate, at: 1)
        selectDate.insert(week, at: 2)
        selectDate.insert(true, at: 3)

        /**确定*/
        doneButton.setTitleColor(UIColor.baseColor, for: UIControlState())
        doneButton.setTitleColor(UIColor.baseColor, for: UIControlState.selected)
        doneButton.setTitleColor(UIColor.baseColor, for: UIControlState.highlighted)
        doneButton.layer.cornerRadius = 3;
        doneButton.layer.borderWidth = 1;
        doneButton.layer.borderColor = UIColor.gray.cgColor;
        doneButton.layer.masksToBounds = true;

        /**取消按钮*/
        cancelButton.setTitleColor(UIColor.baseColor, for: UIControlState())
        cancelButton.setTitleColor(UIColor.baseColor, for: UIControlState.selected)
        cancelButton.setTitleColor(UIColor.baseColor, for: UIControlState.highlighted)
        cancelButton.layer.cornerRadius = 3;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = UIColor.gray.cgColor;
        cancelButton.layer.masksToBounds = true;
    }


    @IBAction func buttonManage(_ sender: AnyObject) {
        if(sender.isEqual(cancelButton)) {
            self.dismiss(animated: true, completion: nil)
        }

        if(sender.isEqual(doneButton)) {
            //self.selectDate = [self timeFormat];
            self.delegate?.getSelectDate(index, date: self.selectDate)
            self.dismiss(animated: true, completion: nil)
        }
    }


    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if(pickerView.isEqual(datePicker)) {
            return 2;
        }

        if(pickerView.isEqual(endDatePicker)) {
            return 2;
        }

        if(pickerView.isEqual(weekDatePicker)) {
            return 1;
        }
        return 1;
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.isEqual(datePicker)) {
            switch (component){
            case 0:
                return 24
            case 1:
                return 60
            default: return 3
            }
        }

        if(pickerView.isEqual(endDatePicker)) {
            switch (component){
            case 0:
                return 24
            case 1:
                return 60
            default: return 3
            }
        }

        if(pickerView.isEqual(weekDatePicker)) {
            switch (component){
            case 0:
                return weekArray.count
            default: return 3
            }
        }
        return 1;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.isEqual(datePicker)) {
            switch (component){
            case 0:
                var timerArray:[String] = []
                for index in 0 ..< 24{
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            case 1:
                var timerArray:[String] = []
                for index in 0 ..< 60{
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            default: return "3"
            }
        }

        if(pickerView.isEqual(endDatePicker)) {
            switch (component){
            case 0:
                var timerArray:[String] = []
                for index in 0 ..< 24{
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            case 1:
                var timerArray:[String] = []
                for index in 0 ..< 60{
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            default: return "3"
            }
        }

        if(pickerView.isEqual(weekDatePicker)) {
            switch (component){
            case 0:
                return weekArray[row]
            default: return "3"
            }
        }
        return "0";
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.isEqual(datePicker)) {
            if(component == 0) {
                startDate.replaceObject(at: 0, with: row)
            }

            if(component == 1) {
                startDate.replaceObject(at: 1, with: row)
            }
            selectDate.replaceObject(at: 0, with: startDate)
        }

        if(pickerView.isEqual(endDatePicker)) {
            if(component == 0) {
                endDate.replaceObject(at: 0, with: row)
            }

            if(component == 1) {
                endDate.replaceObject(at: 1, with: row)
            }
            selectDate.replaceObject(at: 1, with: endDate)
        }

        if(pickerView.isEqual(weekDatePicker)) {
            if(component == 0) {
                week.replaceObject(at: 0, with: row)
            }
            selectDate.replaceObject(at: 2, with: week)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
