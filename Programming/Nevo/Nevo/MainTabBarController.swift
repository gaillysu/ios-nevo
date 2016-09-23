//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import XCGLogger

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:NSMutableArray!
    var selectedItem:UIButton!
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 23);
    var itemView:UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = UIColor(rgba: "#A08455")
        self.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        // Do any additional setup after loading the view.
        //var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            let contll = (nav as! UINavigationController).topViewController
            if contll!.isKind(of: AlarmClockController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("alarmTitle", comment: "")
                contll?.title = NSLocalizedString("alarmTitle", comment: "")
            }

            if contll!.isKind(of: PageViewController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Dashboard", comment: "")
                contll?.title = NSLocalizedString("Dashboard", comment: "")
            }
            
            if contll!.isKind(of: AnalysisController.self){
                
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Analysis", comment: "")
                contll?.title = NSLocalizedString("Analysis", comment: "")
            }

            if contll!.isKind(of: SetingViewController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Setting", comment: "")
                contll?.title = NSLocalizedString("Setting", comment: "")
            }

        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){

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
