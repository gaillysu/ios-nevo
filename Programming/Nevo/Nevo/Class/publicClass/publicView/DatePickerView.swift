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
    func getSelectDate(index:Int,date:NSArray)
}

class DatePickerView: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var endDatePicker: UIPickerView!
    @IBOutlet weak var weekDatePicker: UIPickerView!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var delegate:DatePickerViewDelegate?

    private var startDate:NSMutableArray = NSMutableArray(array: ["0","0"])
    private var endDate:NSMutableArray =  NSMutableArray(array: ["0","0"])
    private var week:NSMutableArray = NSMutableArray(array: ["0"])

    var index:Int = 0

    var selectDate:NSMutableArray = NSMutableArray()

    let weekArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    init() {
        super.init(nibName: "DatePickerView", bundle: NSBundle.mainBundle())

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectDate.insertObject(startDate, atIndex: 0)
        selectDate.insertObject(endDate, atIndex: 1)
        selectDate.insertObject(week, atIndex: 2)
        selectDate.insertObject(true, atIndex: 3)

        /**确定*/
        doneButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        doneButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Selected)
        doneButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Highlighted)
        doneButton.layer.cornerRadius = 3;
        doneButton.layer.borderWidth = 1;
        doneButton.layer.borderColor = UIColor.grayColor().CGColor;
        doneButton.layer.masksToBounds = true;

        /**取消按钮*/
        cancelButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        cancelButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Selected)
        cancelButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Highlighted)
        cancelButton.layer.cornerRadius = 3;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = UIColor.grayColor().CGColor;
        cancelButton.layer.masksToBounds = true;
    }


    @IBAction func buttonManage(sender: AnyObject) {
        if(sender.isEqual(cancelButton)) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        if(sender.isEqual(doneButton)) {
            //self.selectDate = [self timeFormat];
            self.delegate?.getSelectDate(index, date: self.selectDate)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }


    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
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

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.isEqual(datePicker)) {
            switch (component){
            case 0:
                var timerArray:[String] = []
                for(var index:Int = 0;index<24;index++) {
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            case 1:
                var timerArray:[String] = []
                for(var index:Int = 0;index<60;index++) {
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
                for(var index:Int = 0;index<24;index++) {
                    timerArray.append("\(index)")
                }
                return timerArray[row]
            case 1:
                var timerArray:[String] = []
                for(var index:Int = 0;index<60;index++) {
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

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.isEqual(datePicker)) {
            if(component == 0) {
                startDate.replaceObjectAtIndex(0, withObject: row)
            }

            if(component == 1) {
                startDate.replaceObjectAtIndex(1, withObject: row)
            }
            selectDate.replaceObjectAtIndex(0, withObject: startDate)
        }

        if(pickerView.isEqual(endDatePicker)) {
            if(component == 0) {
                endDate.replaceObjectAtIndex(0, withObject: row)
            }

            if(component == 1) {
                endDate.replaceObjectAtIndex(1, withObject: row)
            }
            selectDate.replaceObjectAtIndex(1, withObject: endDate)
        }

        if(pickerView.isEqual(weekDatePicker)) {
            if(component == 0) {
                week.replaceObjectAtIndex(0, withObject: row)
            }
            selectDate.replaceObjectAtIndex(2, withObject: week)
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
