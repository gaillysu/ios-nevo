//
//  MEDUserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class MEDUserSteps: Object {
    dynamic var isUpload:Bool = false;
    dynamic var uid:Int = 0
    dynamic var cid:Int = 0
    dynamic var totalSteps:Int = 0
    dynamic var goalsteps:Int = 0
    dynamic var distance:Int = 0
    dynamic var hourlysteps:String = ""
    dynamic var hourlydistance:String = ""
    dynamic var totalCalories:Double = 0
    dynamic var hourlycalories:String = ""
    dynamic var inZoneTime:Int = 0;
    dynamic var outZoneTime:Int = 0;
    dynamic var inactivityTime:Int = 0;
    dynamic var goalreach:Double = 0.0;
    dynamic var date:TimeInterval = 0
    dynamic var createDate:String = ""
    dynamic var walking_distance:Int = 0
    dynamic var walking_duration:Int = 0
    dynamic var walking_calories:Int = 0
    dynamic var running_distance:Int = 0
    dynamic var running_duration:Int = 0
    dynamic var running_calories:Int = 0
}
