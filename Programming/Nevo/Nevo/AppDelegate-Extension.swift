//
//  AppDelegate-Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

// MARK: - LAUNCH LOGIC
extension AppDelegate {
    func adjustLaunchLogic() {
        
        let user:NSArray = UserProfile.getAll()
        let hasUser:Bool = user.count > 0
        
        let hasWatch:Bool = AppDelegate.getAppDelegate().hasSavedAddress()
        
        if !hasUser {
            let naviController = UINavigationController(rootViewController: LoginController())
            naviController.isNavigationBarHidden = true
            AppDelegate.getAppDelegate().window?.rootViewController = naviController
            AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        } else {
            if !hasWatch {
                let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
                
                let controller = UIApplication.shared.keyWindow?.rootViewController
                controller?.present(naviController, animated: true)
            }
        }
    }
}
