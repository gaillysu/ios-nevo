//
//  ConfigSleepAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 16/1/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class ConfigSleepAlarm: NevoRequest {
    private var mStartHour :Int?
    private var mStartMinute:Int?
    private var mEndtHour :Int?
    private var mEndMinute:Int?
    private var mEnable:Bool?
    private var mWeekday:Int?

    init(startHour:Int,startMinute:Int,endtHour:Int,endMinute:Int,enable:Bool,weekday:Int){
        mStartHour  = startHour
        mStartMinute = startMinute
        mEndtHour = endtHour
        mEndMinute = endMinute
        mEnable = enable
        mWeekday = weekday
    }

    func getStartHour() ->Int {
        return mStartHour!
    }

    func getStartMinute() ->Int {
        return mStartMinute!
    }

    func getEndHour() ->Int {
        return mEndtHour!
    }

    func getEndMinute() ->Int {
        return mEndMinute!
    }

    func getEnable() ->Bool {
        return mEnable!
    }

    func getWeekday() ->Int {
        return mWeekday!
    }
}
