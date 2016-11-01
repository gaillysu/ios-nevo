//
//  SolarHarvest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class SolarHarvest: Object {
    dynamic var uid = 0
    
    dynamic var date:TimeInterval = 0
    
    dynamic var solarTotalTime:Int = 0
    
    dynamic var solarHourlyTime:String = ""
}
