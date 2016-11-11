//
//  MEDUserAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Timepiece
import RealmSwift

class MEDUserAlarm:MEDBaseModel {
    dynamic var timer:TimeInterval = 0.0
    dynamic var label:String = ""
    dynamic var status:Bool = false
    dynamic var alarmWeek:Int = 0 //0-7,0 - disable,1 - Sunday,2 - Monday,3 - Tuesday,4 - Wednesday,5 - Thursday,6 - Friday,7 - Saturday
    dynamic var type:Int = 0 // 0 -> wake; 1 -> sleep

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultAlarm() {
        let realm  = try! Realm()
        let alarm = realm.objects(UserAlarm.self)
        if alarm.count == 0 {
            let currentDate:Date = Date()
            let date1:Date = Date.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 8, minute: 0, second: 0)
            let date2:Date = Date.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 9, minute: 0, second: 0)
            let dateArray:[TimeInterval] = [date1.timeIntervalSince1970,date2.timeIntervalSince1970]
            let nameArray:[String] = [NSLocalizedString("sleep_and_wake", comment: ""),NSLocalizedString("sleep_and_wake", comment: "")]
            for (index,value) in dateArray.enumerated() {
                let alarm:UserAlarm = UserAlarm()
                alarm.timer = value
                alarm.label = nameArray[index]
                alarm.status = false
                alarm.alarmWeek = 2
                alarm.type = 0
                try! realm.write {
                    realm.add(alarm)
                }
            }
        }
    }
}
