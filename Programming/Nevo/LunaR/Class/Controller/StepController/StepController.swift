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
import UIColor_Hex_Swift
import PagingMenuController

private struct PagingMenuOptions: PagingMenuControllerCustomizable {
    
    private var componentType: ComponentType {
        return .PagingController(pagingControllers: pagingControllers)
    }
    
    private var pagingControllers: [UIViewController] {
        let viewController1 = StepGoalSetingController()
        viewController1.view.backgroundColor = UIColor.clearColor()
        let viewController2 = StepsHistoryViewController()
        viewController2.view.backgroundColor = UIColor.clearColor()
        return [viewController1, viewController2]
    }
}

class StepController: PublicClassController,UIActionSheetDelegate {
    private var rightButton:UIBarButtonItem?
    private var goalArray:[Int] = []
    var viewControllers:[UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.view.backgroundColor = UIColor(rgba: "#54575a")

        rightButton = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightBarButtonAction(_:)))
        rightButton?.tintColor = UIColor(rgba: "#7ED8D1")
        self.navigationItem.rightBarButtonItem = rightButton


        if(!AppDelegate.getAppDelegate().isConnected() && AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()){
            let banner = Banner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)
        pagingMenuController.view.backgroundColor = UIColor.redColor()
        pagingMenuController.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.view.frame.size.height)
        self.addChildViewController(pagingMenuController)
        view.addSubview(pagingMenuController.view)
        pagingMenuController.didMoveToParentViewController(self)
        view.backgroundColor = UIColor.redColor()
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
            actionSheet.view.tintColor = UIColor(rgba: "#7ED8D1")

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
    
    func getCurrentVC() -> UIViewController {
        var result:UIViewController?
        
        var window:UIWindow = UIApplication.sharedApplication().keyWindow!
        if (window.windowLevel != UIWindowLevelNormal){
            let windows:NSArray = UIApplication.sharedApplication().windows;
            for tmpWin in windows {
                if (tmpWin.windowLevel == UIWindowLevelNormal){
                    window = tmpWin as! UIWindow;
                    break;
                }
            }
        }
        
        let frontView:UIView = window.subviews[0]
        let nextResponder = frontView.nextResponder()
        
        if nextResponder!.isKindOfClass(UIViewController.classForCoder()) {
            result = nextResponder as? UIViewController
        }else{
            result = window.rootViewController
        }
        
        return result!;
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
}
