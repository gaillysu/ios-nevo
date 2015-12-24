//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class StepController: PublicClassController,toolbarSegmentedDelegate,UIActionSheetDelegate {
    private var currentVC:UIViewController?
    private var stepGoal:StepGoalSetingController?
    private var stepHistorical:StepHistoricalViewController?
    private var rightButton:UIBarButtonItem?
    private var goalArray:[Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = NSLocalizedString("stepGoalTitle", comment: "")

        let toolbar:ToolbarView = ToolbarView(frame: CGRectMake( 0, 0, UIScreen.mainScreen().bounds.width, 35), items: ["Today","History"])
        toolbar.delegate = self
        self.view.addSubview(toolbar)

        rightButton = UIBarButtonItem(title: "Set Goal", style: UIBarButtonItemStyle.Done, target: self, action: Selector("rightBarButtonAction:"))
        rightButton?.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightButton
        
        stepGoal = StepGoalSetingController()
        stepGoal?.view.frame = CGRectMake(0, 35, self.view.frame.size.width, self.view.frame.size.height)
        self.addChildViewController(stepGoal!)
        self.view.addSubview(stepGoal!.view)
        currentVC = stepGoal

        stepHistorical = StepHistoricalViewController()
        stepHistorical?.view.frame = CGRectMake(0, 35, self.view.frame.size.width, self.view.frame.size.height)

    }

    override func viewDidAppear(animated: Bool) {
        let array:NSArray = Presets.getAll()
        goalArray.removeAll()
        for pArray in array {
            let model:Presets = pArray as! Presets
            if(model.status){
                goalArray.append(model.steps)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - rightBarButtonAction
    func rightBarButtonAction(rightBar:UIBarButtonItem){
//        AppDelegate.getAppDelegate().getDailyTrackerInfo()
//        return
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            
            let actionSheet:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()

            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheet.addAction(alertAction)

            for steps:Int in goalArray {
                let alertAction2:UIAlertAction = UIAlertAction(title: "\(steps) steps", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                    if((action.title! as NSString).isEqualToString("\(steps) steps")){
                        NSUserDefaults.standardUserDefaults().setObject(steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                        self.setGoal(NumberOfStepsGoal(steps: steps))
                    }
                }
                actionSheet.addAction(alertAction2)
            }
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }else{
            let actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
            for steps in goalArray {
                actionSheet.addButtonWithTitle("\(steps) steps")
            }
            for button:UIView in actionSheet.subviews{
                button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                button.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
            actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
            actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            actionSheet.actionSheetStyle = UIActionSheetStyle.Default;
            actionSheet.showInView(self.view)
        }
    }

    // MARK: - toolbarSegmentedDelegate
    func didSelectedSegmentedControl(segment:UISegmentedControl){
        if(segment.isKindOfClass(UISegmentedControl.classForCoder())){
            if(segment.selectedSegmentIndex == 1){
                self.replaceController(currentVC!, newController: stepHistorical!)
            }

            if(segment.selectedSegmentIndex == 0){
                self.replaceController(currentVC!, newController: stepGoal!)
            }
        }
    }

    func replaceController(oldController:UIViewController,newController:UIViewController){
        self.addChildViewController(newController)
        self.transitionFromViewController(oldController, toViewController: newController, duration: 0.3, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { (completion) -> Void in

            }) { (finished) -> Void in
                if (finished) {
                    newController.didMoveToParentViewController(self)
                    oldController.willMoveToParentViewController(nil)
                    oldController.removeFromParentViewController()
                    self.currentVC = newController;
                }else{
                    self.currentVC = oldController;

                }
        }
    }

    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex != 0){
            NSUserDefaults.standardUserDefaults().setObject(goalArray[buttonIndex-1], forKey: NUMBER_OF_STEPS_GOAL_KEY)
            setGoal(NumberOfStepsGoal(steps: goalArray[buttonIndex-1]))
        }
    }

    func willPresentActionSheet(actionSheet: UIActionSheet){
        for subViwe in actionSheet.subviews{
            subViwe.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            if(subViwe.isKindOfClass(UIButton.classForCoder())){
                let button:UIButton = subViwe as! UIButton
                button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
        }
    }

    func setGoal(goal:Goal) {
        AppDelegate.getAppDelegate().setGoal(goal)
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
