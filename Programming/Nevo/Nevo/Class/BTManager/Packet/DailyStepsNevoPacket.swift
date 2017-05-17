//
//  DailyStepsNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/3/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DailyStepsNevoPacket: NevoPacket {
    
    /**
    return the Current Daily steps
    */
    func getDailySteps() ->Int
    {
        var dailySteps:Int = Int(getPackets()[0].data2Bytes()[2])
        dailySteps =  dailySteps + Int(getPackets()[0].data2Bytes()[3])<<8
        dailySteps =  dailySteps + Int(getPackets()[0].data2Bytes()[4])<<16
        dailySteps =  dailySteps + Int(getPackets()[0].data2Bytes()[5])<<24
        return dailySteps
    }
    /**
    return the Daily steps Goal
    */
    func getDailyStepsGoal() ->Int
    {
        var dailyStepGoal:Int = Int(getPackets()[0].data2Bytes()[6])
        dailyStepGoal =  dailyStepGoal + Int(getPackets()[0].data2Bytes()[7])<<8
        dailyStepGoal =  dailyStepGoal + Int(getPackets()[0].data2Bytes()[8])<<16
        dailyStepGoal =  dailyStepGoal + Int(getPackets()[0].data2Bytes()[9])<<24
        return dailyStepGoal
    }

    /**
     get Packet data timer
     
     :returns: timer/Year,Month,Day
     */
    func getDateTimer()->Date{
        var year:Int = Int(getPackets()[0].data2Bytes()[10])
        year = year + Int(getPackets()[0].data2Bytes()[11])<<8
        let month:Int = Int(getPackets()[0].data2Bytes()[12])
        let day:Int = Int(getPackets()[0].data2Bytes()[13])
        let hour:Int = Int(getPackets()[0].data2Bytes()[14])
        let minute:Int = Int(getPackets()[0].data2Bytes()[15])
        let seconds:Int = Int(getPackets()[0].data2Bytes()[16])
        let dateString:String = "\(year.to2String())\(month.to2String())\(day.to2String()) \(hour.to2String()):\(minute.to2String()):\(seconds.to2String())"
        return dateString.dateFromFormat("yyyyMMdd HH:mm:ss", locale: DateFormatter().locale)!
    }
   
}
