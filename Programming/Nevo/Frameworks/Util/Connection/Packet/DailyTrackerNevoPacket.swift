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
        var stepGoal:Int = Int(NSData2Bytes(getPackets()[0])[6])
        stepGoal =  stepGoal + Int(NSData2Bytes(getPackets()[0])[7] )<<8
        stepGoal =  stepGoal + Int(NSData2Bytes(getPackets()[0])[8] )<<16
        stepGoal =  stepGoal + Int(NSData2Bytes(getPackets()[0])[9] )<<24
        return stepGoal;
    }
    
    func getDistanceGoal()->Int {
        var goal:Int = Int(NSData2Bytes(getPackets()[0])[10])
        goal += Int(NSData2Bytes(getPackets()[0])[11])
        goal += Int(NSData2Bytes(getPackets()[0])[12])
        goal += Int(NSData2Bytes(getPackets()[0])[13])
        return goal
    }
    
    func getCaloriesGoal()->Int{
        var goal:Int = Int(NSData2Bytes(getPackets()[0])[14])
        goal += Int(NSData2Bytes(getPackets()[0])[15])
        goal += Int(NSData2Bytes(getPackets()[0])[16])
        goal += Int(NSData2Bytes(getPackets()[0])[17])
        return goal
    }
    
    /**
    return History Daily steps
    */
    func getDailySteps() ->Int
    {
        var dailySteps:Int = Int(NSData2Bytes(getPackets()[1])[4] )
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[1])[5] )<<8
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[1])[6] )<<16
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[1])[7] )<<24
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
                if NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[18] != 0xFF
                    && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[19] != 0xFF
                    && NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[2] != 0xFF
                    && NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[3] != 0xFF
                {
                    hourlySteps = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[18] )
                    hourlySteps = hourlySteps + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[19] )<<8
                    hourlySteps = hourlySteps + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[2] )
                    hourlySteps = hourlySteps + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[3] )<<8
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
        var dailyDist:Int = Int(NSData2Bytes(getPackets()[2])[2] )
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[2])[3] )<<8
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[2])[4] )<<16
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[2])[5] )<<24
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[2] != 0xFF
               && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[3] != 0xFF
               && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[4] != 0xFF
               && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[5] != 0xFF
            {
            //walk
                hourlyDisc = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[2] )
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[3] )<<8
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[4] )<<16
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[5] )<<24
            }
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[6] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[7] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[8] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[9] != 0xFF
            {
            //run
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[6] )
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[7] )<<8
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[8] )<<16
                hourlyDisc = hourlyDisc + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[9] )<<24
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
        var dailyCalories:Int = Int(NSData2Bytes(getPackets()[2])[18] )
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[2])[19] )<<8
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[3])[2] )<<16
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[3])[3] )<<24
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[14] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[15] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[16] != 0xFF
                && NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[17] != 0xFF
            {
            hourlyCalories = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[14] )
            hourlyCalories = hourlyCalories + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[15] )<<8
            hourlyCalories = hourlyCalories + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[16] )<<16
            hourlyCalories = hourlyCalories + Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[17] )<<24
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
        var dailySleepTime:Int = Int(NSData2Bytes(getPackets()[4])[10] )
        dailySleepTime =  dailySleepTime + Int(NSData2Bytes(getPackets()[4])[11] )<<8
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[18] != 0xFF
            {
            hourlySleepTime = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[18] )
            }
            HourlySleepTime[i] = hourlySleepTime
        }
        return HourlySleepTime
    }
    
    /**
    return History Daily wake time, minute
    */
    func getDailyWakeTime() ->Int
    {
        var dailyWakeTime:Int = Int(NSData2Bytes(getPackets()[4])[12] )
        dailyWakeTime =  dailyWakeTime + Int(NSData2Bytes(getPackets()[4])[13] )<<8
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[19] != 0xFF
            {
            hourlyWakeTime = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+1])[19] )
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
        var dailyLightTime:Int = Int(NSData2Bytes(getPackets()[4])[14] )
        dailyLightTime =  dailyLightTime + Int(NSData2Bytes(getPackets()[4])[15] )<<8
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3+2])[2] != 0xFF
            {
            hourlyLightTime = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+2])[2] )
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
        var dailyDeepTime:Int = Int(NSData2Bytes(getPackets()[4])[16] )
        dailyDeepTime =  dailyDeepTime + Int(NSData2Bytes(getPackets()[4])[17] )<<8
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
            if NSData2Bytes(getPackets()[HEADERLENGTH+i*3+2])[3] != 0xFF
            {
            hourlyDeepTime = Int(NSData2Bytes(getPackets()[HEADERLENGTH+i*3+2])[3] )
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
        var value:Int = Int(NSData2Bytes(getPackets()[3])[16] )
        value =  value + Int(NSData2Bytes(getPackets()[3])[17] )<<8
        value =  value + Int(NSData2Bytes(getPackets()[3])[18] )<<16
        value =  value + Int(NSData2Bytes(getPackets()[3])[19] )<<24
        return value
    }
    /**
    get in zone time,minute
    */
    func getInZoneTime() ->Int
    {
        var value:Int = Int(NSData2Bytes(getPackets()[4])[2] )
        value =  value + Int(NSData2Bytes(getPackets()[4])[3] )<<8
        value =  value + Int(NSData2Bytes(getPackets()[4])[4] )<<16
        value =  value + Int(NSData2Bytes(getPackets()[4])[5] )<<24
        return value

    }
    /**
    get out zone time,minute
    */
    func getOutZoneTime() ->Int
    {
        var value:Int = Int(NSData2Bytes(getPackets()[4])[6] )
        value =  value + Int(NSData2Bytes(getPackets()[4])[7] )<<8
        value =  value + Int(NSData2Bytes(getPackets()[4])[8] )<<16
        value =  value + Int(NSData2Bytes(getPackets()[4])[9] )<<24
        return value
    }

    /**
    get Packet data timer

    :returns: timer/Year,Month,Day
    */
    func getDateTimer()->Int{
        // TODO This is completely wrong. Date problem with 201698 or 20160908
        var year:Int = Int(NSData2Bytes(getPackets()[0])[2] )
        year = year + Int(NSData2Bytes(getPackets()[0])[3] )<<8
        var month:NSString = NSString(format: "\(NSData2Bytes(getPackets()[0])[4])" as NSString)
        month = month.length >= 2 ? NSString(format: "\(NSData2Bytes(getPackets()[0])[4])" as NSString) : NSString(format: "0\(NSData2Bytes(getPackets()[0])[4])" as NSString)
        var day:NSString = NSString(format: "\(NSData2Bytes(getPackets()[0])[5])" as NSString)
        day = day.length >= 2 ? NSString(format: "\(NSData2Bytes(getPackets()[0])[5])" as NSString) : NSString(format: "0\(NSData2Bytes(getPackets()[0])[5])" as NSString)
        return NSString(format: "\(year)%@%@" as NSString,month,day).integerValue
    }


    /**
     daily Running Steps

     :returns: daily Running Steps
     */
    func getDailyRunningSteps()->Int {
        var total_run_steps:Int = Int(NSData2Bytes(getPackets()[1])[12] )
        total_run_steps =  total_run_steps + Int(NSData2Bytes(getPackets()[1])[13] )<<8
        total_run_steps =  total_run_steps + Int(NSData2Bytes(getPackets()[1])[14] )<<16
        total_run_steps =  total_run_steps + Int(NSData2Bytes(getPackets()[1])[15] )<<24
        return total_run_steps
    }

    /**
     daily Running Distance

     :returns: daily Running Distance
     */
    func getRunningDistance()->Int {
        let packetno = 2
        let offset = 10
        var dailyDist:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[packetno])[packetno+1])<<8
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[packetno])[packetno+2])<<16
        dailyDist =  dailyDist + Int(NSData2Bytes(getPackets()[packetno])[packetno+3])<<24
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
                let value:UInt8 = NSData2Bytes(getPackets()[HEADERLENGTH+i*3])[6+x]
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
        var dailyTimer:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        dailyTimer =  dailyTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        dailyTimer =  dailyTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<16
        dailyTimer =  dailyTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<24
        return dailyTimer/60
    }

    /**
     daily Walking Timer

     :returns: daily Walking Timer
     */
    func getDailyWalkingDuration()->Int {
        let packetno = 3
        let offset = 8
        var dailyWalkingTimer:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        dailyWalkingTimer =  dailyWalkingTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        dailyWalkingTimer =  dailyWalkingTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<16
        dailyWalkingTimer =  dailyWalkingTimer + Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<24
        return dailyWalkingTimer/60
    }

    /**
     daily Walking Steps

     :returns: aily Walking Steps
     */
    func getWalkingSteps()->Int {
        var dailyCalories:Int = Int(NSData2Bytes(getPackets()[1])[8] )
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[1])[9] )<<8
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[1])[10] )<<16
        dailyCalories =  dailyCalories + Int(NSData2Bytes(getPackets()[1])[11] )<<24
        return dailyCalories
    }

    /**
     daily Walking Distance

     :returns: dailyDistance
     */
    func getDailyWalkingDistance()->Int {
        let packetno = 2
        let offset = 6
        var dailyDistance:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        dailyDistance =  dailyDistance + Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        dailyDistance =  dailyDistance + Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<16
        dailyDistance =  dailyDistance + Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<24
        return dailyDistance/100
    }
    
    func getTotalSwimTime()-> Int {
        let packetno = 3
        let offset = 12
        var totalSwim:Int = Int(NSData2Bytes(getPackets()[packetno])[offset])
        totalSwim += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        totalSwim += Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<16
        totalSwim += Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<24
        return totalSwim/60
    }
    
    func getHourlySwimTime()-> [Int] {
        var hourlySwim = [Int](repeating: 0, count: 24)
        let HEADERLENGTH:Int = 6
        var hourlySwimTime:Int = 0
        
        for i:Int in 0 ..< 24 {
            let packetno = HEADERLENGTH+i*3+1;
            let offset = 10;
            hourlySwimTime = 0
            for l:Int in 0..<2 {
                let value = NSData2Bytes(getPackets()[packetno])[offset+l]
                if value != 0xFF {
                    if l==0 {
                        hourlySwimTime += Int(value)
                    }else{
                        hourlySwimTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
                    }
                }
            }
            hourlySwim.replaceSubrange(i..<i+1, with: [hourlySwimTime/60])
        }
        return hourlySwim
    }
}
