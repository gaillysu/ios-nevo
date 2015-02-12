//
//  StepGoalSetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

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

    func bulidStepGoalView(){

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



        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for var index:Int = 1000; index<=30000; index+=10 {
                NSLog("index:\(index)")
                self.indexArray.addObject(index)
            }
            dispatch_async(dispatch_get_main_queue(), {
                // 更新界面
                self.initPickerView()
            });
         });

    }


    // MARK: - PickerView
     private func initPickerView() {
        var PickerbgView:UIView = UIView(frame: CGRectMake(0, 160, self.frame.size.width, self.frame.size.height))
        PickerbgView.backgroundColor = UIColor.clearColor()
        self.addSubview(PickerbgView)

        pickerView = UIPickerView(frame: CGRectMake(0, PickerbgView.frame.size.height-160-50, self.frame.size.width, 160))
        pickerView.backgroundColor = UIColor.grayColor()
        pickerView.delegate = self
        pickerView.dataSource = self
        PickerbgView.addSubview(pickerView)

        let cancelButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        cancelButton.frame = CGRectMake(pickerView.frame.size.width-60, pickerView.frame.origin.y-40, 50, 40)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        PickerbgView.addSubview(cancelButton)


        let tapCancel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapAction:")
        PickerbgView.addGestureRecognizer(tapCancel)

        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

        }) { (Bool) -> Void in

        }

    }

    func tapAction(sender:UITapGestureRecognizer) {

    }

    // MARK: - PickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{
        return 50
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){

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
