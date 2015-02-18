//
//  alarmClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/*
alarmClockView class all button events to follow this protocol
*/
protocol alarmButtonActionCallBack {

    func controllManager(sender:AnyObject)
    
}

class alarmClockView: UIView {

    @IBOutlet var selectedTimerButton: UIButton!
    @IBOutlet var alarmSwitch: UISwitch!

    @IBOutlet var alarmTitle: UILabel!

    @IBOutlet var stepRoundImage: UIImageView!
    
    private var mNoConnectionView:UIView?
    
    private var mCancelButton:UIButton?
    private var mEnterButton:UIButton?
    private var mDatePicker:UIDatePicker?
    let BAG_PICKER_TAG:Int = 1500;//Looking for view using a fixed tag values
    let NO_CONNECT_VIEW:Int = 1200

    private var mNoConnectScanButton:UIButton?
    private var mNoConnectImage:UIImageView?

    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color

    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    
    private var mDelegate:AlarmClockController?

    func bulidAlarmView(delegate:UIViewController) {
        if let callBackDelgate = delegate as? AlarmClockController {
            mDelegate = callBackDelgate
        }
        alarmSwitch.tintColor = UIColor.blackColor()
        alarmSwitch.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()

        alarmTitle.text = NSLocalizedString("alarmLabelTitle", comment: "")
        
    }

    func bulidUI() {
        stepRoundImage.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60);
        stepRoundImage.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0);
    }
    @IBAction func controllEventManager(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender)
    }

    /*
    Create a DatePicker
    */
    func initPickerView() {
        //Create a DatePicker backgroundView
        var PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        PickerbgView.tag = BAG_PICKER_TAG
        self.addSubview(PickerbgView)

        //Create a DatePicker
        let datePicker = UIDatePicker(frame: CGRectMake(0, PickerbgView.frame.size.height-160-50, self.frame.size.width, 160))
        datePicker.backgroundColor = PICKER_BG_COLOR
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.addTarget(self, action: Selector("controllEventManager:"), forControlEvents: UIControlEvents.ValueChanged)
        PickerbgView.addSubview(datePicker)

        mDatePicker = datePicker
        
        let buttonBgView:UIView = UIView(frame: CGRectMake(0, datePicker.frame.origin.y-40, datePicker.frame.size.width, 40))
        buttonBgView.backgroundColor = BUTTONBGVIEW_COLOR
        PickerbgView.addSubview(buttonBgView)

        //Create a cancel button
        let cancelButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        cancelButton.frame = CGRectMake(0, datePicker.frame.origin.y-40, 50, 40)
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

    func bulibNoConnectView() {
        if mNoConnectScanButton==nil {
            mNoConnectionView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
            mNoConnectionView?.backgroundColor = PICKER_BG_COLOR
            mNoConnectionView?.tag = NO_CONNECT_VIEW
            self.addSubview(mNoConnectionView!)

            mNoConnectImage = UIImageView(frame: CGRectMake(0, 0, 160, 160))
            mNoConnectImage?.image = UIImage(named: "connect")
            mNoConnectImage?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)
            mNoConnectImage?.backgroundColor = UIColor.clearColor()
            mNoConnectionView?.addSubview(mNoConnectImage!)

            mNoConnectScanButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            mNoConnectScanButton?.frame = CGRectMake(0, 0, 160, 160)
            mNoConnectScanButton?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)
            mNoConnectScanButton?.setTitle(NSLocalizedString("Connect", comment: ""), forState: UIControlState.Normal)
            mNoConnectScanButton?.backgroundColor = UIColor.clearColor()
            mNoConnectScanButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            mNoConnectScanButton?.addTarget(self, action: Selector("controllEventManager:"), forControlEvents: UIControlEvents.TouchUpInside)
            mNoConnectionView?.addSubview(mNoConnectScanButton!)
        } else {
            
            if let noConnect:UIView = mNoConnectionView {
                UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in
                    
                    noConnect.alpha = 255;
                    
                    }) { (Bool) -> Void in
                        noConnect.hidden=false
                }
            }
        }
    }

    func endConnectRemoveView() {
        
        if let noConnect:UIView = mNoConnectionView {
            UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in
                
                noConnect.alpha = 0;
                
                }) { (Bool) -> Void in
                    noConnect.hidden=true
            }
        }
        
        
        
    }

    /*
    End pickerView performed operation
    */
    func EndAnimation() {
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

    func buttonAnimation(sender:UIImageView) {

        var rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0);
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 10;
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = false
        sender.layer.addAnimation(rotationAnimation, forKey: "NoButtonRotationAnimation")
    }

    /**
    * 动画开始时
    */
    override func animationDidStart(theAnimation:CAAnimation)
    {
        mNoConnectScanButton?.setTitle(NSLocalizedString(" ", comment: ""), forState: UIControlState.Normal)
    }

    /**
    * 动画结束时
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        mNoConnectScanButton?.setTitle(NSLocalizedString("Connect", comment: ""), forState: UIControlState.Normal)
    }

    /*
    Click the cancelButton and enterButton events
    */
    func enterAction(sender:UIButton) {
        if sender.isEqual(mEnterButton)
        {
            mDelegate?.controllManager(sender)
        }
        EndAnimation()
    }

    /*
    Click the tapGesture events
    */
    func tapAction(sender:UITapGestureRecognizer) {
        EndAnimation()
    }
    
    func getDatePicker() -> UIDatePicker? {
        return mDatePicker
    }
    
    func getEnterButton() -> UIButton? {
        return mEnterButton
    }
    
    func getNoConnectionView() -> UIView? {
        return mNoConnectionView
    }
    
    func getNoConnectScanButton() -> UIButton? {
        return mNoConnectScanButton
    }
    
    func getNoConnectImage() -> UIImageView? {
        return mNoConnectImage
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
