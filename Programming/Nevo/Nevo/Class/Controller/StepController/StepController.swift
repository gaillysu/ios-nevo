//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import Timepiece

class StepController: PublicClassController,toolbarSegmentedDelegate,UIActionSheetDelegate {
    private var currentVC:UIViewController?
    private var stepGoal:StepGoalSetingController?
    private var stepHistorical:StepsHistoryViewController?
    private var rightButton:UIBarButtonItem?
    private var goalArray:[Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        AppTheme.navigationbar(self.navigationController!)
        let toolBarHeight:CGFloat = 45.0
        let toolbar:ToolbarView = ToolbarView(frame: CGRectMake( 0, 0, UIScreen.mainScreen().bounds.width, toolBarHeight), items: [NSLocalizedString("today", comment: ""),NSLocalizedString("history", comment: "")])
        toolbar.delegate = self
        self.view.addSubview(toolbar)
        stepGoal = StepGoalSetingController()
        stepGoal?.view.frame = CGRectMake(0, toolBarHeight, self.view.frame.size.width, self.view.frame.size.height-toolBarHeight)
        self.addChildViewController(stepGoal!)
        self.view.addSubview(stepGoal!.view)
        currentVC = stepGoal

        stepHistorical = StepsHistoryViewController()
        stepHistorical?.view.frame = CGRectMake(0, toolBarHeight, self.view.frame.size.width, self.view.frame.size.height-toolBarHeight-113)

        rightButton = UIBarButtonItem(title: NSLocalizedString("set_goal", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: #selector(StepController.rightBarButtonAction(_:)))
        rightButton?.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightButton

//        let leftButton = UIBarButtonItem(title: NSLocalizedString("Video", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: Selector("leftBarButtonAction:"))
//        leftButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
//        self.navigationItem.leftBarButtonItem = leftButton

        if(!AppDelegate.getAppDelegate().isConnected() && AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()){
            let banner = Banner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
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
    func leftBarButtonAction(leftBar:UIBarButtonItem){
        let videoPlay:VideoPlayController = VideoPlayController();
        self.presentViewController(videoPlay, animated: true) { () -> Void in

        }
    }

    func rightBarButtonAction(rightBar:UIBarButtonItem){
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            
            let actionSheet:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()

            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheet.addAction(alertAction)

            let array:NSArray = Presets.getAll()
            for pArray in array {
                let model:Presets = pArray as! Presets
                if(model.status){
                    let titleString:String = NSLocalizedString("\(model.label)", comment: "") + " \(model.steps) " + NSLocalizedString("steps_unit", comment: "")
                    let alertAction2:UIAlertAction = UIAlertAction(title: titleString, style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                        if((action.title! as NSString).isEqualToString(titleString)){
                            NSUserDefaults.standardUserDefaults().setObject(model.steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                            self.setGoal(NumberOfStepsGoal(steps: model.steps))
                        }
                    }
                    actionSheet.addAction(alertAction2)
                }
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
        if(AppDelegate.getAppDelegate().isConnected()){
            let banner = Banner(title: NSLocalizedString("syncing_goal", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            AppDelegate.getAppDelegate().setGoal(goal)
        }else{
            let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stepGoal?.shouldSync = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        stepGoal?.shouldSync = false
    }
}
