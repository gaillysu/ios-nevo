//
//  SetAlarmRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetAlarmRequest: NevoRequest {
   //0~23
    var alarmhour: Int
   //0~59
    var alarmmin:Int
    // true or false
    var alarmenable:Bool
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x41
    }

    init(hour:Int,min:Int,enable:Bool)
    {
        alarmhour = hour
        alarmmin = min
        alarmenable = enable
    }
    
    override func getRawDataEx() -> NSArray {

        var values1 :[UInt8] = [0x00,SetAlarmRequest.HEADER(),
            UInt8(alarmhour&0xFF),
            UInt8(alarmmin&0xFF),
            UInt8(alarmenable ? 7:0),
            0,
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,SetAlarmRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

}


