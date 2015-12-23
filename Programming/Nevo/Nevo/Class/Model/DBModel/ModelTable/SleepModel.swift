//
//  SleepModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepModel: UserDatabaseHelper {

    var date:NSTimeInterval = 0
    var totalSleepTime:Int = 0;
    var hourlySleepTime:String = "";
    var totalWakeTime:Int = 0;
    var hourlyWakeTime:String = "";
    var totalLightTime:Int = 0;
    var hourlyLightTime:String = "";
    var totalDeepTime:Int = 0;
    var hourlyDeepTime:String = "";

    override init() {

    }
}
