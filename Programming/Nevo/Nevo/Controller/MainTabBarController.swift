//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            var contll = (nav as UINavigationController).topViewController
            if contll.isKindOfClass(AlarmClockController){
                NSLog("AlarmClockController:\(contll)")

            }

            if contll.isKindOfClass(StepGoalSetingController){
                NSLog("StepGoalSetingController:\(contll)")
            }

            if contll.isKindOfClass(HomeController){
                NSLog("HomeController:\(contll)")
                contll.tabBarController?.selectedIndex = 1
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
