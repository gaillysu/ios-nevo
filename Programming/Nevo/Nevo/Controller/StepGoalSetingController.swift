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

        stepGoalView.bulidStepGoalView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ButtonAction
    @IBAction func controllManager(sender: AnyObject) {
        if sender.isEqual(stepGoalView.goalButton) {
            NSLog("goalButton")
        }

        if sender.isEqual(stepGoalView.modarateButton) {
            NSLog("modarateButton")
        }

        if sender.isEqual(stepGoalView.intensiveButton) {
            NSLog("intensiveButton")
        }

        if sender.isEqual(stepGoalView.sportiveButton) {
            NSLog("sportiveButton")
        }

        if sender.isEqual(stepGoalView.customButton) {
            NSLog("customButton")
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
