//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:NSMutableArray!
    var selectedItem:UIButton!
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 23);
    var itemView:UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let infoDictionary:[String : AnyObject] = NSBundle.mainBundle().infoDictionary!
        
        let app_Name:String = infoDictionary["CFBundleName"] as! String
        if app_Name == "LunaR" {
            self.tabBar.tintColor = UIColor(rgba: "#7ED8D1")
            self.tabBar.barTintColor = UIColor(rgba: "#333333")
        }else{
            self.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        
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
                
                let app_Name:String = infoDictionary["CFBundleName"] as! String
                if app_Name == "LunaR" {
                    (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Analysis", comment: "")
                    contll?.title = NSLocalizedString("Analysis", comment: "")
                }else{
                    (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("sleepTitle", comment: "")
                    contll?.title = NSLocalizedString("sleepTitle", comment: "")
                }
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
