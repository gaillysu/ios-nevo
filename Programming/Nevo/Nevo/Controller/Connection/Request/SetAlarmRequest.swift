//
//  SetAlarmRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetAlarmRequest: NevoRequest {
   
    override func getRawDataEx() -> NSArray {
        
        let now:NSDate = NSDate()
        let cal:NSCalendar = NSCalendar.currentCalendar()
        let unitFlags:NSCalendarUnit = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        let dd:NSDateComponents = cal.components(unitFlags, fromDate: now);
        
        let year:NSInteger = dd.year;
        let month:NSInteger = dd.month;
        let day:NSInteger = dd.day;
        let hour:NSInteger = dd.hour;
        let min:NSInteger = dd.minute + 1;
        
        var enable :UInt8 = 7 //bit0 =1,bit1 =1,bit2 = 1
        
        var values1 :[UInt8] = [0x00,0x41,
            UInt8(hour&0xFF),
            UInt8(min&0xFF),
            UInt8(enable&0xFF),
            0,
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,0x41,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

}


