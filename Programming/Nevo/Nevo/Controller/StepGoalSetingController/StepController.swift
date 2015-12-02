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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("stepGoalTitle", comment: "")
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - rightBarButtonAction
    func rightBarButtonAction(rightBar:UIBarButtonItem){
        let actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "20000 steps", otherButtonTitles: "30000 steps", "40000 steps")
        actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        actionSheet.actionSheetStyle = UIActionSheetStyle.Default;
        actionSheet.showInView(self.view)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
