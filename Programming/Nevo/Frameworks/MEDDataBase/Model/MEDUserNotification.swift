//
//  MEDUserNotification.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/16.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class MEDUserNotification:MEDBaseModel {
    dynamic var clock:Int = 0
    dynamic var notificationType:String = ""
    dynamic var appid:String = ""
    dynamic var appName:String = ""
    dynamic var receiveDate:TimeInterval = 0
    dynamic var isAddWatch:Bool = false
    dynamic var deleteFlag:Bool = true
    dynamic var colorValue:String = ""
    dynamic var colorName:String = ""
    
    dynamic var colorKey: String = ""
    
    /***************主键可以自己设定设定后不可更改,后面的内容更新都需要根据主键操作*******************/
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    func colorItem() -> MEDNotificationColor? {
        let realm = try! Realm()
        let colorItem = realm.object(ofType: MEDNotificationColor.self, forPrimaryKey: self.colorKey)
        return colorItem
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    
    class func defaultNotificationColor() {
        if(!UserDefaults.standard.bool(forKey: "DefaultNotificationLaunched")){
            let fileResources = Tools.GET_FIRMWARE_FILES("NotificationAppID")
            let notNevoAppID = ["com.tencent.mqq","com.atebits.Tweetie2","com.burbn.instagram","com.facebook.Messenger"]
            let url:URL = fileResources[0] as! URL
            let localDict:NSDictionary = NSDictionary(contentsOf: url)!
            for (key,value) in localDict {
                if (key as! String) == "NotificationAppID" {
                    let valueJson = JSON(value)
                    var indeValue:Int = 0
                    for (key1,value1) in valueJson {
                        let notificationDict = value1.dictionaryValue
                        var isNotNevo:Bool = true
                        
                        for value2 in notNevoAppID {
                            if notificationDict["bundleId"]!.stringValue == value2 {
                                isNotNevo = false;
                            }
                        }
                        
                        if isNotNevo {
                            let userNotification:MEDUserNotification = MEDUserNotification()
                            userNotification.key = notificationDict["bundleId"]!.stringValue
                            if indeValue>5 {
                                userNotification.clock = 12
                            }else{
                                userNotification.clock = (indeValue+1)*2
                            }
                            userNotification.isAddWatch = true
                            userNotification.appName = key1
                            userNotification.notificationType = key1
                            userNotification.receiveDate = Date().timeIntervalSince1970
                            userNotification.appid = notificationDict["bundleId"]!.stringValue
                            userNotification.colorValue = notificationDict["colorValue"]!.stringValue
                            userNotification.colorName = notificationDict["colorName"]!.stringValue
                            
                            // 可以在这里也顺便初始化 MEDNotificationColor 数据库，让每个 MEDUserNotification 都默认对应一个
                            let colorItem: MEDNotificationColor = MEDNotificationColor.factory(name: notificationDict["colorName"]!.stringValue, color: notificationDict["colorValue"]!.stringValue)
                            userNotification.colorKey = colorItem.key
                            _ = colorItem.add()
                            
                            userNotification.deleteFlag = false
                            _ = userNotification.add()
                            indeValue+=1
                        }
                    }
                }
            }
            UserDefaults.standard.set(true, forKey: "DefaultNotificationLaunched")
            UserDefaults.standard.set(true, forKey: "firstDefaultNotification")
        }else{
            UserDefaults.standard.set(false, forKey: "firstDefaultNotification")
        }
    }
}
