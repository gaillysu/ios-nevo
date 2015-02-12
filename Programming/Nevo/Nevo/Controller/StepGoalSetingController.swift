//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class StepGoalSetingController: UIViewController {

    @IBOutlet var stepGoalView: StepGoalSetingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        stepGoalView.bulidStepGoalView(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ButtonAction
    func controllManager(sender:UIButton) {
        if sender.isEqual(stepGoalView.goalButton) {
            NSLog("goalButton")
            stepGoalView.initPickerView()
        }

        if sender.isEqual(stepGoalView.modarateButton) {
            NSLog("modarateButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.modarateButton.selected = true
            stepGoalView.goalButton.setTitle("7000", forState: UIControlState.Normal)
        }

        if sender.isEqual(stepGoalView.intensiveButton) {
            NSLog("intensiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.intensiveButton.selected = true
            stepGoalView.goalButton.setTitle("10000", forState: UIControlState.Normal)

        }

        if sender.isEqual(stepGoalView.sportiveButton) {
            NSLog("sportiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.sportiveButton.selected = true
            stepGoalView.goalButton.setTitle("20000", forState: UIControlState.Normal)
        }

        if sender.isEqual(stepGoalView.customButton) {
            NSLog("customButton")
            //stepGoalView.cleanButtonControlState()
            //stepGoalView.customButton.selected = true
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
