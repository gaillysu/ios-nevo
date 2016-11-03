//
//  UserAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Timepiece

class UserAlarm: NSObject {
    var id:Int = 0
    var timer:TimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false
    var dayOfWeek:Int = 0
    
    // 0 -> wake; 1 -> sleep
    var type:Int = 0 //0-1

    fileprivate var alarmModel:AlarmModel = AlarmModel()

    init(keyDict:NSDictionary) {
        super.init()
        for (key,value) in keyDict {
            self.setValue(value, forKey: key as! String)
        }
    }
    
    override init() {
        super.init()
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        alarmModel.dayOfWeek = dayOfWeek
        alarmModel.type = type
        alarmModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        alarmModel.id = id
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        alarmModel.dayOfWeek = dayOfWeek
        alarmModel.type = type
        return alarmModel.update()
    }

    func remove()->Bool{
        alarmModel.id = id
        return alarmModel.remove()
    }

    class func removeAll()->Bool{
        return AlarmModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = AlarmModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            allArray.add(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = AlarmModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            allArray.add(presets)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return AlarmModel.isExistInTable()
    }

    class func updateTable()->Bool {
        return AlarmModel.updateTable()
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultAlarm(){
        let array = AlarmModel.getAll()
        if(array.count == 0){
            let currentDate:Date = Date()
            let date1:Date = Date.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 8, minute: 0, second: 0)
            let date2:Date = Date.date(year: currentDate.year, month: currentDate.minute, day: currentDate.day, hour: 9, minute: 0, second: 0)
            let dateArray:[TimeInterval] = [date1.timeIntervalSince1970,date2.timeIntervalSince1970]
            let nameArray:[String] = [NSLocalizedString("sleep_and_wake", comment: ""),NSLocalizedString("sleep_and_wake", comment: "")]
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                for index:Int in 0..<dateArray.count {
                    let alarm:UserAlarm = UserAlarm(keyDict: ["id":index,"timer":dateArray[index],"label":nameArray[index],"status":false,"repeatStatus":true,"dayOfWeek":2,"type":0])
                    alarm.add({ (id, completion) -> Void in

                    })
                }
            })

        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
