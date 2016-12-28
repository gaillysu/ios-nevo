//
//  Date+Extension.swift
//  Nevo
//
//  Created by Cloud on 2016/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Timepiece

extension Date{
    /**
     使用gmt Offset 来格式化所在地方的时间
     
     - parameter gmtOffset: Specify the time zone offset(second)
     
     - returns: date format
     */
    static func convertGMTToLocalDateFormat(_ gmtOffset:Int) -> Date {
        let zone:TimeZone       = TimeZone(secondsFromGMT: Int(gmtOffset))!
        let offtSecond:Int      = zone.secondsFromGMT()
        let nowDate:Date        = Date().addingTimeInterval(TimeInterval(offtSecond))
        let sourceTimeZone:TimeZone = TimeZone(abbreviation: "UTC")!//或GMT
        let formatter               = DateFormatter()
        formatter.dateFormat        = "yyyy-MM-dd,h:mm:ss"
        formatter.timeZone          = sourceTimeZone
        let dateString:String       = formatter.string(from: nowDate)
        let dateTime:Date           = dateString.dateFromFormat("yyyy-MM-dd,h:mm:ss", locale: DateFormatter().locale)!
        return dateTime
    }
    
    static func getLocalOffSet() -> Int {
        let zone:TimeZone       = TimeZone.current
        let offtSecond:Int      = zone.secondsFromGMT()
        return offtSecond/60
    }
}
