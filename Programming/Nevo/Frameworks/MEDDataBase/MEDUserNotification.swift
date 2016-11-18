//
//  MEDUserNotification.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/16.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class MEDUserNotification:MEDBaseModel {
    dynamic var clock:Int = 0
    dynamic var notificationType:String = ""
    dynamic var status:Bool = false
    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultNotificationColor() {
        let realm  = try! Realm()
        let notification = realm.objects(MEDUserNotification.self)
        if notification.count == 0 {
            let notificationTypeArray:[String] = ["Calendar", "Facebook", "EMAIL", "CALL", "SMS","WeChat"]
            for (index,value) in notificationTypeArray.enumerated() {
                let userNotification:MEDUserNotification = MEDUserNotification()
                userNotification.key = "\(index)"
                userNotification.clock = (index+1)*2
                userNotification.notificationType = value
                userNotification.status = false
                try! realm.write {
                    realm.add(userNotification)
                }
            }
        }
    }
    
}
