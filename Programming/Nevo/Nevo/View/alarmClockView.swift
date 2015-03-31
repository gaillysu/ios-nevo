//
//  alarmClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class alarmClockView: UIView {

    @IBOutlet var selectedTimerButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var setingButton: UIButton!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    @IBOutlet weak var titleBgView: UIView!
    
    private var mCancelButton:UIButton?
    private var mEnterButton:UIButton?
    private var mDatePicker:UIDatePicker?
    let BAG_PICKER_TAG:Int = 1500;//Looking for view using a fixed tag values

    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color

    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    
    private var mDelegate:ButtonManagerCallBack!

    var animationView:AnimationView!
    
    func bulidAlarmView(delegate:ButtonManagerCallBack,hour:Int,min:Int,enabled:Bool) {
        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("alarmTitle", comment: "")
        title.font = AppTheme.SYSTEMFONTOFSIZE()
        title.textAlignment = NSTextAlignment.Center

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

        setAlarmTime(hour,min: min)

        selectedTimerButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        selectedTimerButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Selected)
        selectedTimerButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Highlighted)
        selectedTimerButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 70)
        
        onButton.setTitle(NSLocalizedString("On", comment:""), forState: UIControlState.Normal)
        onButton.setTitle(NSLocalizedString("On", comment:""), forState: UIControlState.Selected)
        onButton.setTitle(NSLocalizedString("On", comment:""), forState: UIControlState.Highlighted)

        offButton.setTitle(NSLocalizedString("Off", comment:""), forState: UIControlState.Normal)
        offButton.setTitle(NSLocalizedString("Off", comment:""), forState: UIControlState.Selected)
        offButton.setTitle(NSLocalizedString("Off", comment:""), forState: UIControlState.Highlighted)
        if enabled {
            onButton.selected = true
            offButton.selected = false
        }else{
            onButton.selected = false
            offButton.selected = true
        }
        
    }

    func bulidUI() {

    }
    @IBAction func controllEventManager(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender)
    }

    /*
    Create a DatePicker
    */
    func initPickerView(hour:Int,min:Int) {
        //Create a DatePicker backgroundView
        var PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        PickerbgView.tag = BAG_PICKER_TAG
        self.addSubview(PickerbgView)

        //Create a DatePicker
        let datePicker = UIDatePicker(frame: CGRectMake(0, PickerbgView.frame.size.height-160-100, self.frame.size.width, 130))
        datePicker.backgroundColor = PICKER_BG_COLOR
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.addTarget(self, action: Selector("controllEventManager:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //The inital date should be the given hour and min
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        
        let newDate: NSDate = cal.dateBySettingHour(hour, minute: min, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        datePicker.date = newDate
        
        PickerbgView.addSubview(datePicker)



        mDatePicker = datePicker
        
        let buttonBgView:UIView = UIView(frame: CGRectMake(0, datePicker.frame.origin.y-40, datePicker.frame.size.width, 40))
        buttonBgView.backgroundColor = BUTTONBGVIEW_COLOR
        PickerbgView.addSubview(buttonBgView)

        //Create a cancel button
        let cancelButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        cancelButton.frame = CGRectMake(0, datePicker.frame.origin.y-40, 60, 40)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: UIControlState.Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(cancelButton)

        mCancelButton = cancelButton
        
        let enterButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        enterButton.frame = CGRectMake(datePicker.frame.size.width-50, datePicker.frame.origin.y-40, 50, 40)
        enterButton.setTitle(NSLocalizedString("Enter", comment: ""), forState: UIControlState.Normal)
        enterButton.backgroundColor = UIColor.clearColor()
        enterButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        enterButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(enterButton)

        mEnterButton = enterButton

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
                let bgPicker:UIView = view as UIView;
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
    Click the cancelButton and enterButton events
    */
    func enterAction(sender:UIButton) {
        if sender.isEqual(mEnterButton)
        {
            mDelegate?.controllManager(sender)
        }
        endAnimation()
    }

    /*
    Click the tapGesture events
    */
    func tapAction(sender:UITapGestureRecognizer) {
        endAnimation()
    }
    
    func getDatePicker() -> UIDatePicker? {
        return mDatePicker
    }
    
    func getEnterButton() -> UIButton? {
        return mEnterButton
    }
    
    func setAlarmTime(hour:Int,min:Int) {
        selectedTimerButton.setTitle(String(format: "%02d:%02d", hour, min), forState: UIControlState.Normal)
    }
    
    func getEnabled() -> Bool {
     return onButton.selected
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
