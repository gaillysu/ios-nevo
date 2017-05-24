//
//  SyncStepsCache.swift
//  Nevo
//
//  Created by Cloud on 2017/3/29.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

class SyncStepsCache: NSObject,NSCoding {
    var todayDate:Date?
    var todaySteps:Int?
    
    init(date:Date,steps:Int) {
        super.init()
        todayDate = date;
        todaySteps = steps;
    }
    
    // MARK:- 处理需要归档的字段
    func encode(with aCoder:NSCoder) {
        aCoder.encode(todayDate, forKey:"todayDate")
        aCoder.encode(todaySteps, forKey:"todaySteps")
    }
    
    // MARK:- 处理需要解档的字段
    required init(coder aDecoder:NSCoder) {
        super.init()
        todayDate = aDecoder.decodeObject(forKey:"todayDate") as? Date
        todaySteps = aDecoder.decodeObject(forKey:"todaySteps") as? Int
    }
}
