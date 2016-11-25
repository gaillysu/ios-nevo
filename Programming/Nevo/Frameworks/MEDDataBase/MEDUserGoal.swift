//
//  MEDUserGoal.swift
//  Nevo
//
//  Created by Cloud on 2016/11/3.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class MEDUserGoal: MEDBaseModel {
    dynamic var stepsGoal:Int = 0
    dynamic var label:String = ""
    dynamic var status:Bool = false
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
