//
//  Alarm.swift
//  Nevo
//
//  Created by Karl-John Chow on 17/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation
import RealmSwift

class AlarmRealm: Object{
    dynamic var name = ""
    
    // [0-23]
    dynamic var hour = 0
    
    // [0-59]
    dynamic var minute = 0
    
    dynamic var enabled = false
    
    dynamic var repeatAlarm = false
    
    dynamic var dayOfWeek = 0
    
    dynamic var type = 0
    
    // This function is only used for migration from the old DB. 
    func fromAlarmModel(alarmModel:UserAlarm){
        self.name = alarmModel.label
        self.hour = Int(alarmModel.timer.hour)
        self.minute = Int(alarmModel.timer.minute)
        self.enabled = alarmModel.status
        self.repeatAlarm = alarmModel.repeatStatus
        self.dayOfWeek = alarmModel.dayOfWeek
        self.type = alarmModel.type
    }
}
