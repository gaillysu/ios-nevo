//
//  NevoPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Represents a series of packets concatenated together to form the response from the watch
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoPacket {
    private var mPackets:[NSData]=[]
    private var mHeader:UInt8 = 0
    let endFlag:UInt8 = 0xFF
    
    struct DailyHistory
    {
        var TotalSteps:Int;
        var HourlySteps:[Int];
        var Date:NSDate;
    }
    
    init(packets:[NSData])
    {
        if(packets.count >= 2)
        {
        mPackets = packets
        mHeader = NSData2Bytes(mPackets[0])[1]
        }
    }
    
    func getHeader() ->UInt8
    {
        return mHeader
    }
    
    func isLastPacket(packet:RawPacket) ->Bool
    {
        return (NSData2Bytes(packet.getRawData())[0] == 0xFF)
    }
    
    func getDailyTrackerInfo() ->[DailyHistory]
    {
        var days:[DailyHistory] = []
        
        if( mHeader  == 0x24)
        {
           var total:Int = Int(NSData2Bytes(mPackets[1])[12])
            
           var year:Int = 0
           var month:Int = 0
           var day:Int = 0
            
           for (var i:Int = 0; i<total; i++)
            {
                var format:NSDateFormatter = NSDateFormatter()
                format.dateFormat = "yyyyMMddHHmmss"
                
                if(i<=3)
                {
                year  = Int(NSData2Bytes(mPackets[0])[2+4*i] ) + Int(NSData2Bytes(mPackets[0])[3+4*i])<<8
                month = Int(NSData2Bytes(mPackets[0])[4+4*i] )
                day   = Int(NSData2Bytes(mPackets[0])[5+4*i] )
                }
                else if(i == 4)
                {
                    year  = Int(NSData2Bytes(mPackets[0])[2+4*i] ) + Int(NSData2Bytes(mPackets[0])[3+4*i])<<8
                    month = Int(NSData2Bytes(mPackets[1])[2] )
                    day   = Int(NSData2Bytes(mPackets[1])[3] )
                }
                else if(i == 5)
                {
                    year  = Int(NSData2Bytes(mPackets[1])[4] ) + Int(NSData2Bytes(mPackets[1])[5])<<8
                    month = Int(NSData2Bytes(mPackets[1])[6] )
                    day   = Int(NSData2Bytes(mPackets[1])[7] )
                }
                else if(i == 6)
                {
                    year  = Int(NSData2Bytes(mPackets[1])[8] ) + Int(NSData2Bytes(mPackets[1])[9])<<8
                    month = Int(NSData2Bytes(mPackets[1])[10] )
                    day   = Int(NSData2Bytes(mPackets[1])[11] )
                }
                
                //vaild year
                if(year != 0)
                {
                //20150316
                    let mdata:String = String(format: "\(year)%02d%02d000000",month,day)
                    var date:NSDate = format.dateFromString(mdata)!
                    days.append(DailyHistory(TotalSteps: 0, HourlySteps: [24], Date:date))
                }
                
            }

            
        }
        return days
    }
    
    func getDailySteps() ->Int
    {
         if( mHeader  == 0x25 && mPackets.count == 78)
         {
            var dailySteps:Int = Int(NSData2Bytes(mPackets[1])[4] )
            dailySteps =  dailySteps + Int(NSData2Bytes(mPackets[1])[5] )<<8
            dailySteps =  dailySteps + Int(NSData2Bytes(mPackets[1])[6] )<<16
            dailySteps =  dailySteps + Int(NSData2Bytes(mPackets[1])[7] )<<24
            return dailySteps
         }
         return 0
    }
    
    func getHourlySteps() ->[Int]
    {
        var HourlySteps = [Int](count: 24, repeatedValue: 0)
        let offset:Int = 6
        var hourlySteps:Int = 0
        
        if( mHeader  == 0x25 && mPackets.count == 78)
        {
        //get every hour Steps:
            for (var i:Int = 0; i<24; i++)
            {
                if NSData2Bytes(mPackets[offset+i*3])[18] != 0xFF
                    && NSData2Bytes(mPackets[offset+i*3])[19] != 0xFF
                    && NSData2Bytes(mPackets[offset+i*3+1])[2] != 0xFF
                    && NSData2Bytes(mPackets[offset+i*3+1])[3] != 0xFF
                {
                hourlySteps = Int(NSData2Bytes(mPackets[offset+i*3])[18] )
                hourlySteps = hourlySteps + Int(NSData2Bytes(mPackets[offset+i*3])[19] )<<8
                hourlySteps = hourlySteps + Int(NSData2Bytes(mPackets[offset+i*3+1])[2] )
                hourlySteps = hourlySteps + Int(NSData2Bytes(mPackets[offset+i*3+1])[3] )<<8
                HourlySteps[i] = hourlySteps
                }
                
            }
        }
        return HourlySteps
    }
    
}