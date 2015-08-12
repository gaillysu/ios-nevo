//
//  DaySleepSaveModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DaySleepSaveModel: NevoDBModel {
    var DailySleepTime:Int?
    var HourlySleepTime:[Int]?
    var DailyWakeTime:Int?
    var HourlyWakeTime:[Int]?
    var DailyLightTime:Int?
    var HourlyLightTime:[Int]?
    var DailyDeepTime:Int?
    var HourlyDeepTime:[Int]?
    var DailyDist:Int?
    var DailyCalories:Int?

    override init() {

    }

}
