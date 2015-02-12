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

class StepGoalSetingView: UIView,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet var stepLabel: UILabel!
    @IBOutlet var goalButton: UIButton!
    @IBOutlet var modarateButton: UIButton!
    @IBOutlet var intensiveButton: UIButton!
    @IBOutlet var sportiveButton: UIButton!
    @IBOutlet var customButton: UIButton!

    var pickerView:UIPickerView!

    var buttonArray:[UIButton]!

    var indexArray:NSMutableArray = NSMutableArray()

    let BAG_PICKER_TAG:Int = 1300;//Looking for view using a fixed tag values
    let PICKER_BG_COLOR = UIColor(red: 186/255.0, green: 185/255.0, blue: 182/255.0, alpha: 1)//pickerView background color
    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    var mDelegate:StepGoalSetingController!

    func bulidStepGoalView(delegate:UIViewController){

        if let callBackDelgate = delegate as? StepGoalSetingController {
            mDelegate = callBackDelgate
        }

        stepLabel.text = NSLocalizedString("step", comment: "")

        goalButton.setTitle(NSLocalizedString("goalButton", comment: ""), forState: UIControlState.Normal)
        goalButton.setTitle(NSLocalizedString("goalButton", comment: ""), forState: UIControlState.Selected)

        modarateButton.setTitle(NSLocalizedString("Modarate", comment: ""), forState: UIControlState.Normal)
        modarateButton.setTitle(NSLocalizedString("Modarate", comment: ""), forState: UIControlState.Selected)

        intensiveButton.setTitle(NSLocalizedString("Intensive", comment: ""), forState: UIControlState.Normal)
        intensiveButton.setTitle(NSLocalizedString("Intensive", comment: ""), forState: UIControlState.Selected)

        sportiveButton.setTitle(NSLocalizedString("Sportive", comment: ""), forState: UIControlState.Normal)
        sportiveButton.setTitle(NSLocalizedString("Sportive", comment: ""), forState: UIControlState.Selected)

        customButton.setTitle(NSLocalizedString("Custom", comment: ""), forState: UIControlState.Normal)
        customButton.setTitle(NSLocalizedString("Custom", comment: ""), forState: UIControlState.Selected)

        buttonArray = [modarateButton,intensiveButton,sportiveButton,customButton]

        //For loop will stuck the main thread, so you need to for an asynchronous thread to handle this line function
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for var index:Int = 1000; index<=30000; index+=100 {
                NSLog("index:\(index)")
                self.indexArray.addObject(index)
            }
         });

    }

    /*
    Button Action
    */
    @IBAction func buttonAction(sender: AnyObject) {
        //CallBack StepGoalSetingController
        mDelegate.controllManager(sender as UIButton)
    }

    // MARK: - PickerView
    /*
    Create a PickerView
    */
    func initPickerView() {
        //Create a pickerView backgroundView
        var PickerbgView:UIView = UIView(frame: CGRectMake(0, 210, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        PickerbgView.tag = BAG_PICKER_TAG
        self.addSubview(PickerbgView)

        //Create a pickerView
        pickerView = UIPickerView(frame: CGRectMake(0, PickerbgView.frame.size.height-160-50, self.frame.size.width, 160))
        pickerView.backgroundColor = PICKER_BG_COLOR
        pickerView.delegate = self
        pickerView.dataSource = self
        PickerbgView.addSubview(pickerView)

        let buttonBgView:UIView = UIView(frame: CGRectMake(0, pickerView.frame.origin.y-40, pickerView.frame.size.width, 40))
        buttonBgView.backgroundColor = BUTTONBGVIEW_COLOR
        PickerbgView.addSubview(buttonBgView)

        //Create a cancel button
        let cancelButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        cancelButton.frame = CGRectMake(0, pickerView.frame.origin.y-40, 50, 40)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("enterAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        PickerbgView.addSubview(cancelButton)

        let enterButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        enterButton.frame = CGRectMake(pickerView.frame.size.width-50, pickerView.frame.origin.y-40, 50, 40)
        enterButton.setTitle("Enter", forState: UIControlState.Normal)
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

    /*
    Clean up the state of all buttons
    */
    func cleanButtonControlState() {
        for button in buttonArray {
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
        EndAnimation()
    }
    /*
    Click the gesture events
    */
    func tapAction(sender:UITapGestureRecognizer) {
        EndAnimation()
    }

    // MARK: - PickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{
        return 50
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){

        let pickerContent:NSInteger = NSInteger(indexArray.objectAtIndex(row) as Int)
        switch pickerContent {
        case 7000:
            cleanButtonControlState()
            modarateButton.selected = true
            goalButton.setTitle("\(pickerContent)", forState: UIControlState.Normal)

        case 10000:
            cleanButtonControlState()
            intensiveButton.selected = true
            goalButton.setTitle("\(pickerContent)", forState: UIControlState.Normal)

        case 20000:
            cleanButtonControlState()
            sportiveButton.selected = true
            goalButton.setTitle("\(pickerContent)", forState: UIControlState.Normal)

        default:
            NSLog("\(pickerContent)")
            cleanButtonControlState()
            customButton.selected = true
            goalButton.setTitle("\(pickerContent)", forState: UIControlState.Normal)
        }

    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView{
        let labelView:UILabel = UILabel(frame: CGRectMake(0, 0, pickerView.frame.size.width, 50))
        labelView.backgroundColor = UIColor.clearColor()
        labelView.textAlignment = NSTextAlignment.Center
        labelView.font = UIFont.systemFontOfSize(26)
        labelView.text = NSString(format: "%d", indexArray[row] as Int)
        return labelView
    }

    // MARK: - PickerViewDataSource
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }

    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{

        return indexArray.count
    }



}
