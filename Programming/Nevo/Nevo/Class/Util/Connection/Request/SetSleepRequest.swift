//
//  SetSleepRequest.swift
//  Nevo
//
//  Created by leiyuncun on 16/1/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetSleepRequest: NevoRequest {
    //start hour timer 0~23
    var sleepStartHour:Int = 0
    //start min timer 0~59
    var sleepStartMin:Int = 0
    //end hour timer 0~23
    var sleepEndHour:Int = 0
    //end min timer0~59
    var sleepEndMin:Int = 0
    // true or false
    var  sleepAlarmEnable:Bool = false
    var sleepAlarmWeekday:Int = 0

    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x43
    }

    init(sleepAlarm:ConfigSleepAlarm){

        sleepStartHour = sleepAlarm.getStartHour()
        sleepStartMin = sleepAlarm.getStartMinute()
        sleepEndHour = sleepAlarm.getEndHour()
        sleepEndMin = sleepAlarm.getEndMinute()
        sleepAlarmEnable = sleepAlarm.getEnable()
        sleepAlarmWeekday = sleepAlarm.getWeekday()
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x00,SetSleepRequest.HEADER(),
            UInt8(sleepStartHour&0xFF),
            UInt8(sleepStartMin&0xFF),
            UInt8(sleepEndHour&0xFF),
            UInt8(sleepEndMin&0xFF),
            UInt8(sleepAlarmEnable ? 7:0),
            UInt8(sleepAlarmEnable ? 7:0),
            UInt8(sleepAlarmWeekday&0xFF),
            0,0,0,0,0,0,0,0,0,0,0]

        let values2 :[UInt8] = [0xFF,SetSleepRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

}
