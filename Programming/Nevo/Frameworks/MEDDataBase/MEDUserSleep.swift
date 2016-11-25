//
//  MEDUserSleep.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class MEDUserSleep: MEDBaseModel {

    dynamic var isUpload:Bool = false;
    dynamic var uid:Int = 0
    dynamic var cid:Int = 0
    dynamic var date:TimeInterval = 0
    dynamic var totalSleepTime:Int = 0;
    dynamic var hourlySleepTime:String = "";
    dynamic var totalWakeTime:Int = 0;
    dynamic var hourlyWakeTime:String = "";
    dynamic var totalLightTime:Int = 0;
    dynamic var hourlyLightTime:String = "";
    dynamic var totalDeepTime:Int = 0;
    dynamic var hourlyDeepTime:String = "";
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
