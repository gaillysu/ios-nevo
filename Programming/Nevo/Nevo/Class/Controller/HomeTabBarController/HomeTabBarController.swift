//
//  HomeTabBarController.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageControl =  createControl(title:  NSLocalizedString("Dashboard", comment: ""), icon: UIImage(named: "home_icon")!, viewController: UINavigationController(rootViewController: PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)))
        
        let alarmControl = createControl(title:  NSLocalizedString("alarmTitle", comment: ""), icon: UIImage(named: "icon_alarm")!, viewController: UINavigationController(rootViewController: AlarmClockController(nibName: "AlarmClockController", bundle: nil)))
        
        let analysisControl = createControl(title:  NSLocalizedString("Analysis", comment: ""), icon: UIImage(named: "analysis_icon")!, viewController: UINavigationController(rootViewController: AnalysisController(nibName: "AnalysisController", bundle: nil)))

        let settingControl = createControl(title:  NSLocalizedString("Setting", comment: ""), icon: UIImage(named: "icon_settings")!, viewController: UINavigationController(rootViewController: SettingViewController(nibName: "SettingViewController", bundle: nil)))
        self.setViewControllers([pageControl,alarmControl,analysisControl,settingControl], animated: false)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    fileprivate func createControl(title:String, icon:UIImage, viewController:UIViewController) -> UIViewController{
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = icon
        return viewController
    }
    
}
