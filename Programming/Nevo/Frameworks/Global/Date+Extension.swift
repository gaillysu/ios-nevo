//
//  Date+Extension.swift
//  Nevo
//
//  Created by Cloud on 2016/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
 

extension Date {
    
    static func getLocalOffSet() -> Int {
        let zone:TimeZone       = TimeZone.current
        let offtSecond:Int      = zone.secondsFromGMT()
        return offtSecond
    }
}
