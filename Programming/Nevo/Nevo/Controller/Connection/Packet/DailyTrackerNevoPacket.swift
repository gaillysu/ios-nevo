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
        var HourlySteps = [Int](count: 24, repeatedValue: 0)
        let HEADERLENGTH:Int = 6
        var hourlySteps:Int = 0
        
        //get every hour Steps:
        for (var i:Int = 0; i<24; i++)
        {
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

}
