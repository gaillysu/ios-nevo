//
//  Sleep.swift
//  Nevo
//
//  Created by Karl-John Chow on 17/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class SleepRealm: Object {
    
    dynamic var date:NSDate? = nil
    
    dynamic var totalSleepTime:Int = 0;
    
    let hourlySleepTime = List<HourlyIntData>()
    
    dynamic var totalWakeTime:Int = 0;
    
    let hourlyWakeTime = List<HourlyIntData>()
    
    dynamic var totalLightTime:Int = 0;
    
    let hourlyLightTime = List<HourlyIntData>()
    
    dynamic var totalDeepTime:Int = 0;
    
    let hourlyDeepTime = List<HourlyIntData>()

    func fromSleepModel(sleepModel:UserSleep){
        self.date = NSDate(timeIntervalSince1970: sleepModel.date)
        self.totalSleepTime = sleepModel.totalSleepTime
        for element in sleepModel.hourlySleepTime.hourlyDataListForRealm(){
            self.hourlySleepTime.append(element)
        }
        self.totalDeepTime = sleepModel.totalDeepTime
        for element in sleepModel.hourlyDeepTime.hourlyDataListForRealm(){
            self.hourlyDeepTime.append(element)
        }
        self.totalWakeTime = sleepModel.totalWakeTime
        for element in sleepModel.hourlyWakeTime.hourlyDataListForRealm(){
            self.hourlyWakeTime.append(element)
        }
        self.totalLightTime = sleepModel.totalLightTime
        for element in sleepModel.hourlyLightTime.hourlyDataListForRealm(){
            self.hourlyLightTime.append(element)
        }
    }
    
}
