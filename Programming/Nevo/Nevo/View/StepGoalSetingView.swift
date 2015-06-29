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

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet var goalButton: UIButton!
    @IBOutlet var modarateButton: UIButton!
    @IBOutlet var intensiveButton: UIButton!
    @IBOutlet var sportiveButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var setingButton: UIButton!
    @IBOutlet weak var titleBgView: UIView!
    
    private var mPickerView:UIPickerView?

    private var mButtonArray:[UIButton]=[]

    private var mIndexArray:NSMutableArray = NSMutableArray()

    let BAG_PICKER_TAG:Int = 1300//Looking for view using a fixed tag values
    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color
    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    
    private var mDelegate:ButtonManagerCallBack!

    private var mEnterButton:UIButton?

    var animationView:AnimationView!

    func bulidStepGoalView(delegate:ButtonManagerCallBack){

        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("stepGoalTitle", comment: "")
        title.font = AppTheme.SYSTEMFONTOFSIZE()
        title.textAlignment = NSTextAlignment.Center

        mDelegate = delegate

        animationView = AnimationView(frame: self.frame, delegate: delegate)

        stepLabel.text = NSLocalizedString("Step", comment: "")

        goalButton.setTitle(NSLocalizedString("goalButton", comment: ""), forState: UIControlState.Normal)
        goalButton.setTitle(NSLocalizedString("goalButton", comment: ""), forState: UIControlState.Selected)
        goalButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 60)


        modarateButton.setTitle(NSLocalizedString("Modarate", comment: ""), forState: UIControlState.Normal)
        modarateButton.setTitle(NSLocalizedString("Modarate", comment: ""), forState: UIControlState.Selected)
        modarateButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        modarateButton.layer.borderWidth = 1.0;
        modarateButton.layer.borderColor = UIColor.grayColor().CGColor;

        intensiveButton.setTitle(NSLocalizedString("Intensive", comment: ""), forState: UIControlState.Normal)
        intensiveButton.setTitle(NSLocalizedString("Intensive", comment: ""), forState: UIControlState.Selected)
        intensiveButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        intensiveButton.layer.borderWidth = 1.0;
        intensiveButton.layer.borderColor = UIColor.grayColor().CGColor;

        sportiveButton.setTitle(NSLocalizedString("Sportive", comment: ""), forState: UIControlState.Normal)
        sportiveButton.setTitle(NSLocalizedString("Sportive", comment: ""), forState: UIControlState.Selected)
        sportiveButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        sportiveButton.layer.borderWidth = 1.0;
        sportiveButton.layer.borderColor = UIColor.grayColor().CGColor;

        mButtonArray = [modarateButton,intensiveButton,sportiveButton]

        //For loop will stuck the main thread, so you need to for an asynchronous thread to handle this line function
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for var index:Int = 1000; index<=30000; index+=1000 {
                self.mIndexArray.addObject(index)
            }
         });
        
        setNumberOfStepsGoal(7000)

    }

    func bulidUI() {

    }
    /*
    Button Action
    */
    @IBAction func buttonAction(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender as! UIButton)
    }

    // MARK: - PickerView
    /*
    Create a PickerView
    */
    func initPickerView(initialValue:Int) {
        //Create a pickerView backgroundView
        var PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
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
        let cancelButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        cancelButton.frame = CGRectMake(0, mPickerView!.frame.origin.y-40, 70, 40)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: UIControlState.Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(cancelButton)

        let enterButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
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
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView{
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

    func setNumberOfStepsGoal(goal:Int){

        goalButton.setTitle("\(goal)", forState: UIControlState.Normal)
        
        
        cleanButtonControlState()
        
        if(goal==NumberOfStepsGoal().LOW_INTENSITY_STEPS) {
            
            modarateButton.selected = true
            
        } else if(goal==NumberOfStepsGoal().MEDIUM_INTENSITY_STEPS) {
            
            intensiveButton.selected = true
            
        } else if(goal==NumberOfStepsGoal().HIGH_INTENSITY_STEPS) {
            
            sportiveButton.selected = true
            
        }
    }

    func getEnterButton() -> UIButton? {
        return mEnterButton
    }

}
