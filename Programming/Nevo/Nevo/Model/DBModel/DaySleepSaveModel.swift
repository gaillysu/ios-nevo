//
//  DaySleepSaveModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DaySleepSaveModel: NevoDBModel {
    var Steps:NSString?
    var sleepDate:NSString?
    var DailySleepTime:NSString?
    var HourlySleepTime:NSString?
    var DailyWakeTime:NSString?
    var HourlyWakeTime:NSString?
    var DailyLightTime:NSString?
    var HourlyLightTime:NSString?
    var DailyDeepTime:NSString?
    var HourlyDeepTime:NSString?
    var DailyDist:NSString?
    var DailyCalories:NSString?

    override init() {

    }

}
