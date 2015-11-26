//
//  alarmClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class alarmClockView: UIView {

    /// All buttons id value
    private let switchAndButtonTag1:Int = 0
    private let switchAndButtonTag2:Int = 1
    private let switchAndButtonTag3:Int = 2

    let BAG_PICKER_TAG:Int = 1500;//Looking for view using a fixed tag values

    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color

    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    
    private var mDelegate:ButtonManagerCallBack!

    var animationView:AnimationView!
    
    func bulidAlarmView(delegate:ButtonManagerCallBack,array:[Alarm]) {
        //title.text = NSLocalizedString("alarmTitle", comment: "")

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)
        for aItem in array{
            let alarm:Alarm = aItem as Alarm
            let value:Int = alarm.getIndex()
            switch value{
                case 0: break
                    //setOnAlarm(alarm.getHour(), min: alarm.getMinute(), enabled: alarm.getEnable(), andSelectedBt: selectedTimerButton1, toAlarmSwicth: alarmSwicth1)
                case 1: break
                    //setOnAlarm(alarm.getHour(), min: alarm.getMinute(), enabled: alarm.getEnable(), andSelectedBt: selectedTimerButton2, toAlarmSwicth: alarmSwicth2)
                case 2: break
                    //setOnAlarm(alarm.getHour(), min: alarm.getMinute(), enabled: alarm.getEnable(), andSelectedBt: selectedTimerButton3, toAlarmSwicth: alarmSwicth3)
                default: break
                    //setOnAlarm(alarm.getHour(), min: alarm.getMinute(), enabled: alarm.getEnable(), andSelectedBt: selectedTimerButton1, toAlarmSwicth: alarmSwicth1)
            }
        }
    }


    @IBAction func controllEventManager(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender)

    }

    func setOnAlarm(hour:Int,min:Int,enabled:Bool ,andSelectedBt:UIButton ,toAlarmSwicth:UISwitch) {
        setAlarmTime(hour,min: min,andObject: andSelectedBt)
        if(enabled){
            toAlarmSwicth.on = true
        }else{
            toAlarmSwicth.on = false
        }
    }

    /*
    Create a DatePicker
    */
    func initPickerView(hour:Int,min:Int) {
        //Create a DatePicker backgroundView
        let PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        PickerbgView.tag = BAG_PICKER_TAG
        self.addSubview(PickerbgView)

        //Create a DatePicker
        let datePicker = UIDatePicker(frame: CGRectMake(0, PickerbgView.frame.size.height-160-100, self.frame.size.width, 130))
        datePicker.backgroundColor = PICKER_BG_COLOR
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.addTarget(self, action: Selector("controllEventManager:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //The inital date should be the given hour and min
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate: NSDate = cal.dateBySettingHour(hour, minute: min, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        datePicker.date = newDate
        
        PickerbgView.addSubview(datePicker)
        
        let buttonBgView:UIView = UIView(frame: CGRectMake(0, datePicker.frame.origin.y-40, datePicker.frame.size.width, 40))
        buttonBgView.backgroundColor = BUTTONBGVIEW_COLOR
        PickerbgView.addSubview(buttonBgView)

        //Create a cancel button
        let cancelButton = UIButton(type:UIButtonType.System)
        cancelButton.frame = CGRectMake(0, datePicker.frame.origin.y-40, 60, 40)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: UIControlState.Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(cancelButton)
        
        let enterButton = UIButton(type:UIButtonType.System)
        enterButton.frame = CGRectMake(datePicker.frame.size.width-50, datePicker.frame.origin.y-40, 50, 40)
        enterButton.setTitle(NSLocalizedString("Enter", comment: ""), forState: UIControlState.Normal)
        enterButton.backgroundColor = UIColor.clearColor()
        enterButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        enterButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(enterButton)

        //Create a click gesture
        let tapCancel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapAction:")
        PickerbgView.addGestureRecognizer(tapCancel)

        //With animation will create the view
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in
            var frame:CGRect = PickerbgView.frame
            frame.origin.y = 0;
            PickerbgView.frame = frame;
            }) { (Bool) -> Void in
                
        }
        
    }


    /*
    End pickerView performed operation
    */
    func endAnimation() {
        for view : AnyObject in self.subviews{
            if view is UIView{
                let bgPicker:UIView = view as! UIView;
                if bgPicker.tag == self.BAG_PICKER_TAG {

                    UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

                        var frame:CGRect = bgPicker.frame
                        frame.origin.y = 210;
                        bgPicker.frame = frame;

                        }) { (Bool) -> Void in

                            bgPicker.removeFromSuperview()
                    }

                    
                }
            }
        }
        
    }



    /*
    Click the tapGesture events
    */
    func tapAction(sender:UITapGestureRecognizer) {
        endAnimation()
    }

    
    func setAlarmTime(hour:Int,min:Int,andObject:UIButton!) {
        if(andObject != nil){
            andObject!.setTitle(String(format: "%02d:%02d", hour, min), forState: UIControlState.Normal)
            andObject!.setTitle(String(format: "%02d:%02d", hour, min), forState: UIControlState.Selected)
            andObject!.setTitle(String(format: "%02d:%02d", hour, min), forState: UIControlState.Highlighted)
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
