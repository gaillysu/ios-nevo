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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tabBar.tintColor = UIColor.getBaseColor()
            self.tabBar.barTintColor = UIColor.getGreyColor()
        }
        // Do any additional setup after loading the view.
        //var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            let contll = (nav as! UINavigationController).topViewController
            if contll!.isKind(of: AlarmClockController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("alarmTitle", comment: "")
                contll?.title = NSLocalizedString("alarmTitle", comment: "")
                DispatchQueue.once(token: "MainTabBarController_alarmTitle", block: {
                    (nav as! UINavigationController).tabBarItem.imageInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
                })
            }

            if contll!.isKind(of: PageViewController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Dashboard", comment: "")
                contll?.title = NSLocalizedString("Dashboard", comment: "")
                
                DispatchQueue.once(token: "MainTabBarController_Dashboard", block: {
                    (nav as! UINavigationController).tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
                })
            }
            
            if contll!.isKind(of: AnalysisController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Analysis", comment: "")
                contll?.title = NSLocalizedString("Analysis", comment: "")
                
                DispatchQueue.once(token: "MainTabBarController_Analysis", block: {
                    (nav as! UINavigationController).tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
                })
            }

            if contll!.isKind(of: SetingViewController.self){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Setting", comment: "")
                contll?.title = NSLocalizedString("Setting", comment: "")
                
                DispatchQueue.once(token: "MainTabBarController_Setting", block: {
                    (nav as! UINavigationController).tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
                })
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


// MARK: - LUNAR EXTENSION
extension MainTabBarController {
    fileprivate func scaleImage(_ image:UIImage, to size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

