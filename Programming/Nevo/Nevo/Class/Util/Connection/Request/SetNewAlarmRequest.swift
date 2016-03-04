//
//  SetNewAlarmRequest.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetNewAlarmRequest: NevoRequest {
    //0~23
    var alarmhour:Int = 0
    //0~59
    var alarmmin:Int = 0
    //0~6End sleep 7-13 start sleep
    var alarmNumber:Int = 0
    // true or false
    var alarmWeekday:Int = 0

    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x41
    }

    init(alarm:NewAlarm){
        super.init()
        alarmhour = alarm.getHour()
        alarmmin = alarm.getMinute()
        alarmNumber = alarm.getAlarmNumber()
        alarmWeekday = alarm.getAlarmWeekday()
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x00,SetNewAlarmRequest.HEADER(),
            UInt8(alarmhour&0xFF),
            UInt8(alarmmin&0xFF),
            UInt8(alarmNumber&0xFF),
            UInt8(alarmWeekday&0xFF),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        let values2 :[UInt8] = [0xFF,SetNewAlarmRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
}
