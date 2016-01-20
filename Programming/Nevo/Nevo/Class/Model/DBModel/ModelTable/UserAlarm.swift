//
//  UserAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserAlarm: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var timer:NSTimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false

    private var alarmModel:AlarmModel = AlarmModel()

    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("timer"), forKey: "timer")
        self.setValue(keyDict.objectForKey("label"), forKey: "label")
        self.setValue(keyDict.objectForKey("status"), forKey: "status")
        self.setValue(keyDict.objectForKey("repeatStatus"), forKey: "repeatStatus")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        alarmModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        alarmModel.id = id
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        return alarmModel.update()
    }

    func remove()->Bool{
        alarmModel.id = id
        return alarmModel.remove()
    }

    class func removeAll()->Bool{
        return AlarmModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = AlarmModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = AlarmModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus])
            allArray.addObject(presets)
        }
        return allArray
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultAlarm(){
        let array = AlarmModel.getAll()
        if(array.count == 0){
            let currentDate:NSDate = NSDate()
            let date1:NSDate = NSDate.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 8, minute: 0, second: 0)
            let date2:NSDate = NSDate.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 9, minute: 0, second: 0)
            let dateArray:[NSTimeInterval] = [date1.timeIntervalSince1970,date2.timeIntervalSince1970]
            let nameArray:[String] = ["Weekly days","Weekend"]
            for (var index:Int = 0; index < dateArray.count ; index++) {
                let alarm:UserAlarm = UserAlarm(keyDict: ["id":index,"timer":dateArray[index],"label":nameArray[index],"status":false,"repeatStatus":true])
                alarm.add({ (id, completion) -> Void in

                })
            }
        }
    }
}
