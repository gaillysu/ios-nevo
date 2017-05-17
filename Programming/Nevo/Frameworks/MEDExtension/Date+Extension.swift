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
    
    /**
     transfer GMT NSDate to locale NSDate
     */
    func gmtDate2LocaleDate() ->Date {
        let sourceTimeZone:TimeZone = TimeZone(identifier: "UTC")!
        let destinationTimeZone:TimeZone = TimeZone.autoupdatingCurrent
        let sourceGMTOffset:Int = sourceTimeZone.secondsFromGMT(for: self)
        let destinationGMTOffset:Int = destinationTimeZone.secondsFromGMT(for: self)
        let interval:TimeInterval = TimeInterval(destinationGMTOffset) - TimeInterval(sourceGMTOffset)
        let destinationDateNow:Date = Date(timeInterval: interval, since: self)
        return destinationDateNow
    }
}
