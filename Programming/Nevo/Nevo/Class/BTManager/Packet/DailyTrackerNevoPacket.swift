//
//  DailyTrackerNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/3/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DailyTrackerNevoPacket: NevoPacket {

    /**
     return Steps goal

     :returns: goal
     */
    func getStepsGoal()->Int {
        var stepGoal:Int = Int(getPackets()[0].data2Bytes()[6])
        stepGoal =  stepGoal + Int(getPackets()[0].data2Bytes()[7])<<8
        stepGoal =  stepGoal + Int(getPackets()[0].data2Bytes()[8])<<16
        stepGoal =  stepGoal + Int(getPackets()[0].data2Bytes()[9])<<24
        return stepGoal;
    }
    
    func getDistanceGoal()->Int {
        var goal:Int = Int(getPackets()[0].data2Bytes()[10])
        goal += Int(getPackets()[0].data2Bytes()[11])
        goal += Int(getPackets()[0].data2Bytes()[12])
        goal += Int(getPackets()[0].data2Bytes()[13])
        return goal
    }
    
    func getCaloriesGoal()->Int{
        var goal:Int = Int(getPackets()[0].data2Bytes()[14])
        goal += Int(getPackets()[0].data2Bytes()[15])
        goal += Int(getPackets()[0].data2Bytes()[16])
        goal += Int(getPackets()[0].data2Bytes()[17])
        return goal
    }
    
    /**
    return History Daily steps
    */
    func getDailySteps() ->Int
    {
        var dailySteps:Int = Int(getPackets()[1].data2Bytes()[4])
        dailySteps =  dailySteps + Int(getPackets()[1].data2Bytes()[5])<<8
        dailySteps =  dailySteps + Int(getPackets()[1].data2Bytes()[6])<<16
        dailySteps =  dailySteps + Int(getPackets()[1].data2Bytes()[7])<<24
        return dailySteps
    }
    /**
    return History Hourly steps
    */
    func getHourlySteps() ->[Int]
    {
        var HourlySteps = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlySteps:Int = 0
        
        //get every hour Steps:
        for i:Int in 0 ..< 24 {
                if getPackets()[HEADERLENGTH+i*3].data2Bytes()[18] != 0xFF
                    && getPackets()[HEADERLENGTH+i*3].data2Bytes()[19] != 0xFF
                    && getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[2] != 0xFF
                    && getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[3] != 0xFF
                {
                    hourlySteps = Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[18])
                    hourlySteps = hourlySteps + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[19])<<8
                    hourlySteps = hourlySteps + Int(getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[2])
                    hourlySteps = hourlySteps + Int(getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[3])<<8
                    HourlySteps[i] = hourlySteps
                }
                
        }        
        return HourlySteps
    }
    
    //new added from APP:v1.2.2,FW:v18/v31
    
    /**
    return History Daily Dist, meter
    */
    func getDailyDist() ->Int
    {
        var dailyDist:Int = Int(getPackets()[2].data2Bytes()[2] )
        dailyDist =  dailyDist + Int(getPackets()[2].data2Bytes()[3])<<8
        dailyDist =  dailyDist + Int(getPackets()[2].data2Bytes()[4])<<16
        dailyDist =  dailyDist + Int(getPackets()[2].data2Bytes()[5])<<24
        return dailyDist/100
    }
    /**
    return History Hourly Disc, meter
    */
    func getHourlyDist() ->[Int]
    {
        var HourlyDist = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyDisc:Int = 0
        
        //get every hour Disc:
        for i:Int in 0 ..< 24 {
            hourlyDisc = 0
            if getPackets()[HEADERLENGTH+i*3].data2Bytes()[2] != 0xFF
               && getPackets()[HEADERLENGTH+i*3].data2Bytes()[3] != 0xFF
               && getPackets()[HEADERLENGTH+i*3].data2Bytes()[4] != 0xFF
               && getPackets()[HEADERLENGTH+i*3].data2Bytes()[5] != 0xFF
            {
            //walk
                hourlyDisc = Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[2] )
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[3])<<8
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[4])<<16
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[5])<<24
            }
            if getPackets()[HEADERLENGTH+i*3].data2Bytes()[6] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[7] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[8] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[9] != 0xFF
            {
            //run
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[6])
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[7])<<8
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[8])<<16
                hourlyDisc = hourlyDisc + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[9])<<24
            }
            HourlyDist[i] = hourlyDisc/100
        }
        return HourlyDist
    }

    /**
    return History Daily Calories, kcal
    */
    func getDailyCalories() ->Int
    {
        var dailyCalories:Int = Int(getPackets()[2].data2Bytes()[18] )
        dailyCalories =  dailyCalories + Int(getPackets()[2].data2Bytes()[19] )<<8
        dailyCalories =  dailyCalories + Int(getPackets()[3].data2Bytes()[2] )<<16
        dailyCalories =  dailyCalories + Int(getPackets()[3].data2Bytes()[3] )<<24
        return dailyCalories/1000
    }
    /**
    return History Hourly Calories, kcal
    */
    func getHourlyCalories() ->[Int]
    {
        var HourlyCalories = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyCalories:Int = 0
        
        //get every hour Calories:
        for i:Int in 0 ..< 24 {
            hourlyCalories = 0
            if getPackets()[HEADERLENGTH+i*3].data2Bytes()[14] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[15] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[16] != 0xFF
                && getPackets()[HEADERLENGTH+i*3].data2Bytes()[17] != 0xFF
            {
            hourlyCalories = Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[14])
            hourlyCalories = hourlyCalories + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[15])<<8
            hourlyCalories = hourlyCalories + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[16])<<16
            hourlyCalories = hourlyCalories + Int(getPackets()[HEADERLENGTH+i*3].data2Bytes()[17])<<24
            }
            HourlyCalories[i] = hourlyCalories/100
        }
        return HourlyCalories
    }
    
    
    /**
    return History Daily sleep time, minute
    */
    func getDailySleepTime() ->Int
    {
        var dailySleepTime:Int = Int(getPackets()[4].data2Bytes()[10] )
        dailySleepTime =  dailySleepTime + Int(getPackets()[4].data2Bytes()[11])<<8
        return dailySleepTime
    }
    /**
    return History Hourly sleep time, minute
    */
    func getHourlySleepTime() ->[Int]
    {
        var HourlySleepTime = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlySleepTime:Int = 0
        
        //get every hour SleepTime:
        for i:Int in 0 ..< 24 {
            hourlySleepTime = 0
            if getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[18] != 0xFF {
                hourlySleepTime = Int(getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[18])
            }
            HourlySleepTime[i] = hourlySleepTime
        }
        return HourlySleepTime
    }
    
    /**
    return History Daily wake time, minute
    */
    func getDailyWakeTime() ->Int {
        var dailyWakeTime:Int = Int(getPackets()[4].data2Bytes()[12] )
        dailyWakeTime =  dailyWakeTime + Int(getPackets()[4].data2Bytes()[13])<<8
        return dailyWakeTime
    }
    /**
    return History Hourly wake time, minute
    */
    func getHourlyWakeTime() ->[Int]
    {
        var HourlyWakeTime = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyWakeTime:Int = 0
        
        //get every hour wake Time:
        for i:Int in 0 ..< 24 {
            hourlyWakeTime = 0
            if getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[19] != 0xFF {
                hourlyWakeTime = Int(getPackets()[HEADERLENGTH+i*3+1].data2Bytes()[19])
            }
            HourlyWakeTime[i] = hourlyWakeTime
        }
        return HourlyWakeTime
    }
    
    
    /**
    return History Daily light time, minute
    */
    func getDailyLightTime() ->Int
    {
        var dailyLightTime:Int = Int(getPackets()[4].data2Bytes()[14])
        dailyLightTime =  dailyLightTime + Int(getPackets()[4].data2Bytes()[15])<<8
        return dailyLightTime
    }
    /**
    return History Hourly light time, minute
    */
    func getHourlyLightTime() ->[Int]
    {
        var HourlyLightTime = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyLightTime:Int = 0
        
        //get every hour light Time:
        for i:Int in 0 ..< 24 {
            hourlyLightTime = 0
            if getPackets()[HEADERLENGTH+i*3+2].data2Bytes()[2] != 0xFF {
                hourlyLightTime = Int(getPackets()[HEADERLENGTH+i*3+2].data2Bytes()[2])
            }
            HourlyLightTime[i] = hourlyLightTime
        }
        return HourlyLightTime
    }

    /**
    return History Daily deep time, minute
    */
    func getDailyDeepTime() ->Int
    {
        var dailyDeepTime:Int = Int(getPackets()[4].data2Bytes()[16])
        dailyDeepTime =  dailyDeepTime + Int(getPackets()[4].data2Bytes()[17])<<8
        return dailyDeepTime
    }
    /**
    return History Hourly deep time, minute
    */
    func getHourlyDeepTime() ->[Int]
    {
        var HourlyDeepTime = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyDeepTime:Int = 0
        
        //get every hour deep Time:
        for i:Int in 0 ..< 24 {
            hourlyDeepTime = 0
            if getPackets()[HEADERLENGTH+i*3+2].data2Bytes()[3] != 0xFF {
                hourlyDeepTime = Int(getPackets()[HEADERLENGTH+i*3+2].data2Bytes()[3])
            }
            HourlyDeepTime[i] = hourlyDeepTime
        }
        return HourlyDeepTime
    }

    /**
    get inactivity time, minute
    */
    func getInactivityTime() ->Int
    {
        var value:Int = Int(getPackets()[3].data2Bytes()[16])
        value =  value + Int(getPackets()[3].data2Bytes()[17])<<8
        value =  value + Int(getPackets()[3].data2Bytes()[18])<<16
        value =  value + Int(getPackets()[3].data2Bytes()[19])<<24
        return value
    }
    /**
    get in zone time,minute
    */
    func getInZoneTime() ->Int
    {
        var value:Int = Int(getPackets()[4].data2Bytes()[2])
        value =  value + Int(getPackets()[4].data2Bytes()[3])<<8
        value =  value + Int(getPackets()[4].data2Bytes()[4])<<16
        value =  value + Int(getPackets()[4].data2Bytes()[5])<<24
        return value

    }
    /**
    get out zone time,minute
    */
    func getOutZoneTime() ->Int
    {
        var value:Int = Int(getPackets()[4].data2Bytes()[6])
        value =  value + Int(getPackets()[4].data2Bytes()[7])<<8
        value =  value + Int(getPackets()[4].data2Bytes()[8])<<16
        value =  value + Int(getPackets()[4].data2Bytes()[9])<<24
        return value
    }

    /**
    get Packet data timer

    :returns: timer/Year,Month,Day
    */
    func getDateTimer()->Date{
        var year:Int = Int(getPackets()[0].data2Bytes()[2])
        year = year + Int(getPackets()[0].data2Bytes()[3])<<8
        let month:Int = Int(getPackets()[0].data2Bytes()[4])
        let day:Int = Int(getPackets()[0].data2Bytes()[5])
        
        let dateString:String = "\(year.to2String())\(month.to2String())\(day.to2String())"
        return dateString.dateFromFormat("yyyyMMdd", locale: DateFormatter().locale)!
    }


    /**
     daily Running Steps

     :returns: daily Running Steps
     */
    func getDailyRunningSteps()->Int {
        var total_run_steps:Int = Int(getPackets()[1].data2Bytes()[12])
        total_run_steps =  total_run_steps + Int(getPackets()[1].data2Bytes()[13])<<8
        total_run_steps =  total_run_steps + Int(getPackets()[1].data2Bytes()[14])<<16
        total_run_steps =  total_run_steps + Int(getPackets()[1].data2Bytes()[15])<<24
        return total_run_steps
    }

    /**
     daily Running Distance

     :returns: daily Running Distance
     */
    func getRunningDistance()->Int {
        let packetno = 2
        let offset = 10
        var dailyDist:Int = Int(getPackets()[packetno].data2Bytes()[offset])
        dailyDist =  dailyDist + Int(getPackets()[packetno].data2Bytes()[packetno+1])<<8
        dailyDist =  dailyDist + Int(getPackets()[packetno].data2Bytes()[packetno+2])<<16
        dailyDist =  dailyDist + Int(getPackets()[packetno].data2Bytes()[packetno+3])<<24
        return dailyDist/100
    }

    /**
     hour running distance

     - returns: hour running distance array
     */
    func getHourlyRunningDistance()->[Int] {
        var HourlyRunningDistance = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlyRunningTime:Int = 0

        //get every hour running distance:
        for i:Int in 0 ..< 24 {
            hourlyRunningTime = 0
            for x:Int in 0 ..< 4 {
                let value:UInt8 = getPackets()[HEADERLENGTH+i*3].data2Bytes()[6+x]
                if value != 0xFF {
                    hourlyRunningTime = hourlyRunningTime + Int(value) << (8*x)
                }
            }
            HourlyRunningDistance[i] = hourlyRunningTime/100
        }
        return HourlyRunningDistance
    }

    /**
     daily Running Timer

     :returns: daily Running Timer
     */
    func getDailyRunningDuration()->Int {
        let packetno = 3
        let offset = 4
        var dailyTimer:Int = Int(getPackets()[packetno].data2Bytes()[offset])
        dailyTimer =  dailyTimer + Int(getPackets()[packetno].data2Bytes()[offset+1])<<8
        dailyTimer =  dailyTimer + Int(getPackets()[packetno].data2Bytes()[offset+2])<<16
        dailyTimer =  dailyTimer + Int(getPackets()[packetno].data2Bytes()[offset+3])<<24
        return dailyTimer/60
    }

    /**
     daily Walking Timer

     :returns: daily Walking Timer
     */
    func getDailyWalkingDuration()->Int {
        let packetno = 3
        let offset = 8
        var dailyWalkingTimer:Int = Int(getPackets()[packetno].data2Bytes()[offset])
        dailyWalkingTimer =  dailyWalkingTimer + Int(getPackets()[packetno].data2Bytes()[offset+1])<<8
        dailyWalkingTimer =  dailyWalkingTimer + Int(getPackets()[packetno].data2Bytes()[offset+2])<<16
        dailyWalkingTimer =  dailyWalkingTimer + Int(getPackets()[packetno].data2Bytes()[offset+3])<<24
        return dailyWalkingTimer/60
    }

    /**
     daily Walking Steps

     :returns: aily Walking Steps
     */
    func getWalkingSteps()->Int {
        var dailyCalories:Int = Int(getPackets()[1].data2Bytes()[8])
        dailyCalories =  dailyCalories + Int(getPackets()[1].data2Bytes()[9])<<8
        dailyCalories =  dailyCalories + Int(getPackets()[1].data2Bytes()[10])<<16
        dailyCalories =  dailyCalories + Int(getPackets()[1].data2Bytes()[11])<<24
        return dailyCalories
    }

    /**
     daily Walking Distance

     :returns: dailyDistance
     */
    func getDailyWalkingDistance()->Int {
        let packetno = 2
        let offset = 6
        var dailyDistance:Int = Int(getPackets()[packetno].data2Bytes()[offset])
        dailyDistance =  dailyDistance + Int(getPackets()[packetno].data2Bytes()[offset+1])<<8
        dailyDistance =  dailyDistance + Int(getPackets()[packetno].data2Bytes()[offset+2])<<16
        dailyDistance =  dailyDistance + Int(getPackets()[packetno].data2Bytes()[offset+3])<<24
        return dailyDistance/100
    }
    
    func getTotalHarvestTime()-> Int {
        let packetno = 3
        let offset = 12
        var totalSwim:Int = Int(getPackets()[packetno].data2Bytes()[offset])
        totalSwim += Int(getPackets()[packetno].data2Bytes()[offset+1])<<8
        totalSwim += Int(getPackets()[packetno].data2Bytes()[offset+2])<<16
        totalSwim += Int(getPackets()[packetno].data2Bytes()[offset+3])<<24
        return totalSwim/60
    }
    
    func getHourlyHarestTime()-> [Int] {
        var hourlySwim = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlySwimTime:Int = 0
        
        for i:Int in 0 ..< 24 {
            let packetno = HEADERLENGTH+i*3+1;
            let offset = 10;
            hourlySwimTime = 0
            for l:Int in 0..<2 {
                let value = getPackets()[packetno].data2Bytes()[offset+l]
                if value != 0xFF {
                    if l==0 {
                        hourlySwimTime += Int(value)
                    }else{
                        hourlySwimTime += Int(getPackets()[packetno].data2Bytes()[offset+1])<<8
                    }
                }
            }
            hourlySwim.replaceSubrange(i..<i+1, with: [hourlySwimTime/60])
        }
        return hourlySwim
    }
}
