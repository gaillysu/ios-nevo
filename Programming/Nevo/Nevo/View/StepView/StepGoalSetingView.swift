//
//  StepGoalSetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/*
StepGoalSetingView class all button events to follow this protocol
*/
protocol StepGoalButtonActionCallBack {

    func controllManager(sender:UIButton)

}

class StepGoalSetingView: UIView,UIPickerViewDataSource,UIPickerViewDelegate {

    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout
    var progressView:CircleProgressView?

    private var mPickerView:UIPickerView?

    private var mButtonArray:[UIButton]=[]

    private var mIndexArray:NSMutableArray = NSMutableArray()

    let BAG_PICKER_TAG:Int = 1300//Looking for view using a fixed tag values
    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color
    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    
    private var mDelegate:ButtonManagerCallBack!

    private var mEnterButton:UIButton?

    //var animationView:AnimationView!

    func bulidStepGoalView(delegate:ButtonManagerCallBack,navigation:UINavigationItem){
        mDelegate = delegate

        //animationView = AnimationView(frame: self.frame, delegate: delegate)
        mClockTimerView.currentTimer()
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0)//Using the center property determines the location of the ClockView
        mClockTimerView.frame = CGRectMake(mClockTimerView.frame.origin.x, 45, mClockTimerView.frame.size.width, mClockTimerView.frame.size.height)
        self.addSubview(mClockTimerView)

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        progressView?.setProgress(0.5)
        self.layer.addSublayer(progressView!)

    }

    /*
    Button Action
    */
    @IBAction func buttonAction(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender)
    }

    // MARK: - PickerView
    /*
    Create a PickerView
    */
    func initPickerView(initialValue:Int) {
        //Create a pickerView backgroundView
        let PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        PickerbgView.tag = BAG_PICKER_TAG
        self.addSubview(PickerbgView)

        //Create a pickerView
        mPickerView = UIPickerView(frame: CGRectMake(0, PickerbgView.frame.size.height-160-100, self.frame.size.width, 160))
        mPickerView?.backgroundColor = PICKER_BG_COLOR
        mPickerView?.dataSource = self
        mPickerView?.delegate = self
        PickerbgView.addSubview(mPickerView!)

        let buttonBgView:UIView = UIView(frame: CGRectMake(0, mPickerView!.frame.origin.y-40, mPickerView!.frame.size.width, 40))
        buttonBgView.backgroundColor = BUTTONBGVIEW_COLOR
        PickerbgView.addSubview(buttonBgView)

        //Create a cancel button
        let cancelButton:UIButton = UIButton(type:UIButtonType.System)
        cancelButton.frame = CGRectMake(0, mPickerView!.frame.origin.y-40, 70, 40)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: UIControlState.Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(cancelButton)

        let enterButton = UIButton(type:UIButtonType.System)
        enterButton.frame = CGRectMake(mPickerView!.frame.size.width-50, mPickerView!.frame.origin.y-40, 50, 40)
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
        
        mPickerView!.selectRow(((initialValue/1000)-1) , inComponent: 0, animated: false)


    }

    /*
    End pickerView performed operation
    */
    func EndAnimation() {
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
    Clean up the state of all buttons
    */
    func cleanButtonControlState() {
        for button in mButtonArray {
            let controlButton:UIButton = button as UIButton;
            if controlButton.selected {
                controlButton.selected = false
            }
        }
    }

    /*
    Click the cancelButton and enterButton events
    */
    func enterAction(sender:UIButton) {
        if sender.isEqual(mEnterButton){

            mDelegate?.controllManager(sender)
        }
        EndAnimation()
    }
    /*
    Click the gesture events
    */
    func tapAction(sender:UITapGestureRecognizer) {
        EndAnimation()
    }

    // MARK: - PickerViewDelegate
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView{
        let labelView:UILabel = UILabel(frame: CGRectMake(0, 0, pickerView.frame.size.width, 50))
        labelView.backgroundColor = UIColor.clearColor()
        labelView.textAlignment = NSTextAlignment.Center
        labelView.font = UIFont.systemFontOfSize(26)
        labelView.text = NSString(format: "%d", mIndexArray[row] as! Int) as String
        return labelView
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    // MARK: - PickerViewDataSource
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }

    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{

        return mIndexArray.count
    }
    
    func getNumberOfStepsGoal() -> Int{
        let row = mPickerView?.selectedRowInComponent(0)
        return mIndexArray.objectAtIndex(row!) as! Int
    }

    func getEnterButton() -> UIButton? {
        return mEnterButton
    }

    // MARK: - toolbarSegmentedDelegate
    func didSelectedSegmentedControl(segment:UISegmentedControl){

    }
}
