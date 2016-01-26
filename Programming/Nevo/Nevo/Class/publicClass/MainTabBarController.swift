//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:NSMutableArray!
    var selectedItem:UIButton!
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 23);
    var itemView:UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        // Do any additional setup after loading the view.
        //var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            let contll = (nav as! UINavigationController).topViewController
            if contll!.isKindOfClass(AlarmClockController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("alarmTitle", comment: "")
                contll?.title = NSLocalizedString("alarmTitle", comment: "")
                AppTheme.DLog("AlarmClockController:\(contll)")

            }

            if contll!.isKindOfClass(StepController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("you_reached", comment: "")
                contll?.title = NSLocalizedString("you_reached", comment: "")
                AppTheme.DLog("StepController:\(contll)")
            }
            
            if contll!.isKindOfClass(SleepController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("sleepTitle", comment: "")
                contll?.title = NSLocalizedString("sleepTitle", comment: "")
                AppTheme.DLog("SetingViewController:\(contll)")
            }

            if contll!.isKindOfClass(SetingViewController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Setting", comment: "")
                contll?.title = NSLocalizedString("Setting", comment: "")
                AppTheme.DLog("SetingViewController:\(contll)")
            }

        }
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){

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
