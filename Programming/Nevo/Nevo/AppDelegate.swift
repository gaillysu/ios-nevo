//
//  AppDelegate.swift
//  Nevo
//
//  Created by Karl on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var isFirsttimeLaunch: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "kIsNotFirstTimeLaunch")
            UserDefaults.standard.set(true, forKey: "kIsNotFirstTimeLaunch")
            return !result
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        appGlobalConfig()
        
        IQKeyboardManager.sharedManager().enable = true
        
        _ = MEDDataBaseManager.manager
        
        _ = MEDNetworkManager.manager
        
        /**
        Initialize the BLE Manager
        */
        _ = ConnectionManager.manager
        
        let userDefaults = UserDefaults.standard;
        if userDefaults.getDurationSearch() == 0 {
            userDefaults.setDurationSearch(version: 15)
        }
        adjustLaunchLogic()
        
        return true
    }

    
}

// MARK: - 调整 App 的启动逻辑
extension AppDelegate {
    func appGlobalConfig() {
        UINavigationBar.appearance().tintColor = UIColor.baseColor
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.getBarColor()
        UITabBar.appearance().tintColor = UIColor.baseColor
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.getBarColor())
        //set navigationBar font style and font color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    func adjustLaunchLogic() {
        let hasWatch:Bool = ConnectionManager.manager.hasSavedAddress()
        let isFirsttimeLaunch = self.isFirsttimeLaunch
        if isFirsttimeLaunch {
            let naviController = UINavigationController(rootViewController: LoginController())
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = naviController
            self.window?.makeKeyAndVisible()
        } else {
            if !hasWatch {
                let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
                naviController.isNavigationBarHidden = true
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = naviController
                self.window?.makeKeyAndVisible()
            }else{
                initTabBarControl()
            }
        }
        
        /// Alter the entry of app here when testing a single module.
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
        #if DEBUG
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.window?.makeKeyAndVisible()
        #endif
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
    }
    
    func initTabBarControl() {
        let homeTabbar = HomeTabBarController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeTabbar
        self.window?.makeKeyAndVisible()
    }
    
}
