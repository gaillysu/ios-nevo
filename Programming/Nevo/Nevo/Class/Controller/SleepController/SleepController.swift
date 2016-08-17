//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepController: PublicClassController,toolbarSegmentedDelegate {
    var querss:SleepHistoryViewController?
    var sleepTrking:SleepTrackingController?
    private var currentVC:UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        AppTheme.navigationbar(self.navigationController!)
        let toolBarHeight:CGFloat = 45.0
        let toolbar:ToolbarView = ToolbarView(frame: CGRectMake( 0, 0, UIScreen.mainScreen().bounds.width, toolBarHeight), items: [NSLocalizedString("last_night", comment: ""),NSLocalizedString("history", comment: "")])
        toolbar.delegate = self
        self.view.addSubview(toolbar)

        sleepTrking = SleepTrackingController()
        sleepTrking?.view.frame = CGRectMake(0, toolBarHeight, self.view.frame.size.width, UIScreen.mainScreen().bounds.size.height-toolBarHeight)
        self.addChildViewController(sleepTrking!)
        self.view.addSubview(sleepTrking!.view)
        currentVC = sleepTrking

        querss = SleepHistoryViewController()
        querss?.view.frame = CGRectMake(0, toolBarHeight, self.view.frame.size.width, UIScreen.mainScreen().bounds.size.height-toolBarHeight-113)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didSelectedSegmentedControl(segment:UISegmentedControl){
        if(segment.isKindOfClass(UISegmentedControl.classForCoder())){
            if(segment.selectedSegmentIndex == 1){
                self.replaceController(currentVC!, newController: querss!)
            }

            if(segment.selectedSegmentIndex == 0){
                self.replaceController(currentVC!, newController: sleepTrking!)
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
