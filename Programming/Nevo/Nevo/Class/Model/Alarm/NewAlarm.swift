//
//  NewAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NewAlarm: NSObject {
    //0~23
    private var mAlarmHour:Int = 0
    //0~59
    private var mAlarmMin:Int = 0
    //0~6End sleep 7-13 start sleep
    private var mAlarmNumber:Int = 0
    // 0-7
    private var mAlarmWeekday:Int = 0

    init(alarmhour: Int, alarmmin:Int,alarmNumber:Int,alarmWeekday:Int){
        super.init()
        mAlarmHour = alarmhour
        mAlarmMin  = alarmmin
        mAlarmNumber = alarmNumber
        mAlarmWeekday = alarmWeekday
    }

    func getAlarmNumber()->Int{
        return mAlarmNumber
    }

    func getHour() ->Int
    {
        return mAlarmHour
    }
    func getMinute() ->Int
    {
        return mAlarmMin
    }
    func getAlarmWeekday() ->Int
    {
        return mAlarmWeekday
    }
}
