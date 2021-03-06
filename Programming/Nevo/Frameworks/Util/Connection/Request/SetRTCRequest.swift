//
//  SetRTCRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetRTCRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x01
    }
    
    override func getRawDataEx() -> NSArray {
        
        
        let now:Date = Date()
        let cal:Calendar = Calendar.current
        let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        
        let year:NSInteger = dd.year!;
        let month:NSInteger = dd.month!;
        let day:NSInteger = dd.day!;
        let hour:NSInteger = dd.hour!;
        let min:NSInteger = dd.minute!;
        let sec:NSInteger = dd.second!;
        
        let values1 :[UInt8] = [0x00,SetRTCRequest.HEADER(),
            UInt8(year&0xFF),
            UInt8((year>>8)&0xFF),
            UInt8(month&0xFF),
            UInt8(day&0xFF),
            UInt8(hour&0xFF),
            UInt8(min&0xFF),
            UInt8(sec&0xFF),
            0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,SetRTCRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }

}
