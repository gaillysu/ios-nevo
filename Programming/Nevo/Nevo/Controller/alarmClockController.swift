//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class alarmClockController: UIViewController,alarmButtonActionCallBack {

    @IBOutlet var alarmView: alarmClockView!

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmView.bulidAlarmView(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stringFromDate(date:NSDate) -> String {
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }
    /*
    call back Button Action
    */
    func controllManager(sender:AnyObject){


        if sender.isEqual(alarmView.selectedTimerButton){
            alarmView.initPickerView()
            NSLog("alarmView.selectedTimerButton")
        }

        if sender.isEqual(alarmView.alarmSwitch){
            NSLog("alarmView.alarmSwitch")
        }

        if sender.isEqual(alarmView.datePicker) {
            let dateButtonTitle = stringFromDate(alarmView.datePicker.date)
            alarmView.selectedTimerButton.setTitle(dateButtonTitle as String, forState: UIControlState.Normal)

            NSLog("datePicker:%@",dateButtonTitle)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
