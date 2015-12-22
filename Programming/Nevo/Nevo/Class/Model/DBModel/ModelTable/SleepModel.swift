//
//  SleepModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepModel: UserDatabaseHelper {

    var UserId:Int = 0
    var created:Int = 0
    var TotalSleepTime:Int = 0;
    var HourlySleepTime:String = "";
    var TotalWakeTime:Int = 0;
    var HourlyWakeTime:String = "";
    var TotalLightTime:Int = 0;
    var HourlyLightTime:String = "";
    var TotalDeepTime:Int = 0;
    var HourlyDeepTime:String = "";

    override init() {

    }
}
