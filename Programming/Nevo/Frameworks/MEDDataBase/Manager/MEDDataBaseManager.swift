//
//  MEDDataBaseManager.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class MEDDataBaseManager: NSObject {
    static let manager = MEDDataBaseManager()
    
    fileprivate override init() {
        super.init()
        
        updateDataBaseConfig()
        
        MEDUserGoal.defaultUserGoal()
        MEDUserNotification.defaultNotificationColor()
        MEDUserAlarm.defaultAlarm()
    }
    
    func updateDataBaseConfig() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
}
