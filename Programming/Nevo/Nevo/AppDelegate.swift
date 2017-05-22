//
//  AppDelegate.swift
//  Nevo
//
//  Created by Karl on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire
import BRYXBanner
import Fabric
import Crashlytics
import LTNavigationBar
import IQKeyboardManagerSwift
import SwiftEventBus
import UIColor_Hex_Swift
import XCGLogger
import SwiftyTimer
import CoreLocation
import Solar
import RealmSwift


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

    class func getAppDelegate()->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        // Override point for customization after application launch
        UINavigationBar.appearance().tintColor = UIColor.baseColor
        UITabBar.appearance().isTranslucent = true
         UITabBar.appearance().backgroundColor = UIColor.getBarColor()
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.getBarColor())
        //set navigationBar font style and font color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        updateDataBase()
        
        _ = MEDNetworkManager.manager
        
        IQKeyboardManager.sharedManager().enable = true

        MEDUserGoal.defaultUserGoal()
        MEDUserNotification.defaultNotificationColor()
        MEDUserAlarm.defaultAlarm()
        
        /**
        Initialize the BLE Manager
        */
        _ = ConnectionManager.manager
        
        let userDefaults = UserDefaults.standard;
        //lastSync = userDefaults.double(forKey: LAST_SYNC_DATE_KEY)
        if userDefaults.getDurationSearch() == 0 {
            userDefaults.setDurationSearch(version: 15)
        }
        adjustLaunchLogic()
        
        return true
    }

    func updateDataBase() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
}

// MARK: - 调整 App 的启动逻辑
extension AppDelegate {
    func adjustLaunchLogic() {
        let hasWatch:Bool = ConnectionManager.manager.hasSavedAddress()
        let isFirsttimeLaunch = AppDelegate.getAppDelegate().isFirsttimeLaunch
        if isFirsttimeLaunch {
            let naviController = UINavigationController(rootViewController: LoginController())
            AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
            AppDelegate.getAppDelegate().window?.rootViewController = naviController
            AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        } else {
            if !hasWatch {
                let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
                naviController.isNavigationBarHidden = true
                AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
                AppDelegate.getAppDelegate().window?.rootViewController = naviController
                AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
            }
        }
        
        /// Alter the entry of app here when testing a single module.
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
        #if DEBUG
            
            AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
            AppDelegate.getAppDelegate().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        #endif
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
    }
    
}
