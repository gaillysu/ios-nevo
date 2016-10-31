//
//  WorldClockItem.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

class WorldClockItem:NSObject {
    var time:String = ""
    var sunriseTime:String = ""
    var sunsetTime:String = ""
    
    override init() {
        super.init()
    }
    
    init(time:String, sunriseTime:String, sunsetTime:String) {
        self.time = time
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
    }
}
