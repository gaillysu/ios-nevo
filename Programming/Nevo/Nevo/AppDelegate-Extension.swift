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
        let loginController = LoginController()
        self.window?.rootViewController = loginController
    }
}
