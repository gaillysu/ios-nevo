//
//  StepsModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class StepsModel: UserDatabaseHelper {
    var Userid:Int = 0
    var Steps:Int = 0
    var Distance:Int = 0
    var Hourlysteps:String = ""
    var Hourlydistance:String = ""
    var Calories:Double = 0
    var Hourlycalories:String = ""
    var InZoneTime:Int = 0;
    var OutZoneTime:Int = 0;
    var InactivityTime:Int = 0;
    var goalreach:Double = 0;
    var Date:NSDate = NSDate()
    var createdDate:NSDate = NSDate()

    override init() {

    }
}
