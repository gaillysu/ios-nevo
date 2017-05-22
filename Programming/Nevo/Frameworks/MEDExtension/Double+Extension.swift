//
//  Double+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

extension Double {
    func to2Double() -> Double {
        return NSString(format: "%.2f", self).doubleValue
    }
    
    func toDouble() -> Double {
        return NSString(format: "%.0f", self).doubleValue
    }
    
    func toInt() -> Int {
        return Int(self)
    }
    
    func timerFormatValue()->String {
        let hours:Int = Int(self).hours.value
        let minutes:Int = Int((self-Double(hours))*60).minutes.value
        if hours == 0 {
            return String(format:"%d m",minutes)
        }
        return String(format:"%d h %d m",hours,minutes)
    }
}
