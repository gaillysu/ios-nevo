//
//  AlarmSectionModelItem.swift
//  Nevo
//
//  Created by Cloud on 2017/5/24.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

struct AlarmSectionModelItem {
    var alarmTimer: String
    var alarmTile: String
    var describing:String
    var status:Bool
    
    init(timer:String,title:String, describing:String,state:Bool) {
        self.alarmTimer = timer
        self.alarmTile = title
        self.describing = describing
        self.status = state
    }
}
