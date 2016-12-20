//
//  WorldClockUtil.swift
//  Nevo
//
//  Created by Karl-John Chow on 25/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import Timepiece

class WorldClockUtil {
    
    class func getStartDateForDST(_ timezone:Timezone) -> Date{
        return getDateFrom(timezone.dstDayInMonthStart, month: timezone.dstMonthStart, time: timezone.dstTimeStart)
    }
    
    class func getStopDateForDST(_ timezone:Timezone) -> Date{
        return getDateFrom(timezone.dstDayInMonthEnd, month: timezone.dstMonthEnd, time: timezone.dstTimeEnd)
    }
    
    class func getDateFrom(_ dateInMonth:Int, month:Int, time:String) -> Date!{
        let date = Date()
        
        var utcComp = DateComponents()
        utcComp.year = date.year
        utcComp.month = date.month
        utcComp.day = date.day
        utcComp.timeZone = TimeZone(identifier: "utc")
        // not sure if this works
        let dateInUTC = Calendar.current.date(from: utcComp)!
        
        if let unpackedTime = time.dateFromFormat("HH:mm:ss.SSS"){
            return dateInUTC.change(year: dateInUTC.year, month: month, day: dateInMonth, hour: unpackedTime.hour, minute: unpackedTime.minute, second: 0)
        }else{
            print("Couldn't parse Time in timezone!!")
            return dateInUTC.change(year: dateInUTC.year, month: month, day: dateInMonth, hour: 0, minute: 0, second: 0)
        }
    }
    
    class func getBluetoothWorldClockModel(_ worldClockArray: [City]) -> [(cityName:String,gmtOffset:Float)]{
        var convertedWorldClockArray:[(cityName:String,gmtOffset:Float)] = []
        for city:City in worldClockArray {
            if let timezone = city.timezone{
                convertedWorldClockArray.append((city.name,(Float(timezone.getOffsetFromUTC())/60)))
            }
        }
        return convertedWorldClockArray
    }
}
