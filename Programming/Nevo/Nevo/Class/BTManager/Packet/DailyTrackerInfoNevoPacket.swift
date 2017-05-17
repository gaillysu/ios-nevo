//
//  DailyTrackerInfoNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/3/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DailyTrackerInfoNevoPacket: NevoPacket {
         
    /**
    return Tracker history summary infomation, MAX total 7 days(include Today)
    the actually days is saved by [DailyHistory].count
    */
    func getDailyTrackerInfo() ->[DailyHistory]
    {
            var days:[DailyHistory] = []
        
            let total:Int = Int(getPackets()[1].data2Bytes()[12])
            var year:Int = 0
            var month:Int = 0
            var day:Int = 0
            
            for i:Int in 0 ..< total {
                let format:DateFormatter = DateFormatter()
                format.dateFormat = "yyyyMMddHHmmss"
                
                if (i<=3) {
                    year  = Int(getPackets()[0].data2Bytes()[2+4*i] ) + Int(getPackets()[0].data2Bytes()[3+4*i])<<8
                    month = Int(getPackets()[0].data2Bytes()[4+4*i] )
                    day   = Int(getPackets()[0].data2Bytes()[5+4*i] )
                }else if (i == 4) {
                    year  = Int(getPackets()[0].data2Bytes()[2+4*i] ) + Int(getPackets()[0].data2Bytes()[3+4*i])<<8
                    month = Int(getPackets()[1].data2Bytes()[2] )
                    day   = Int(getPackets()[1].data2Bytes()[3] )
                }else if (i == 5) {
                    year  = Int(getPackets()[1].data2Bytes()[4] ) + Int(getPackets()[1].data2Bytes()[5])<<8
                    month = Int(getPackets()[1].data2Bytes()[6] )
                    day   = Int(getPackets()[1].data2Bytes()[7] )
                }else if (i == 6) {
                    year  = Int(getPackets()[1].data2Bytes()[8] ) + Int(getPackets()[1].data2Bytes()[9])<<8
                    month = Int(getPackets()[1].data2Bytes()[10] )
                    day   = Int(getPackets()[1].data2Bytes()[11] )
                }
                
                //vaild year,month, day
                if((year>1970 && year<2050)  && (month>=1 && month<=12) && (day>=1 && day<=31))
                {
                    //20150316
                    let mdata:String = String(format: "\(year)%02d%02d000000",month,day)
                    let date:Date = format.date(from: mdata)!
                    days.append(DailyHistory(date:date))
                }
                
            }
            
            
        
        return days
    }
   
}
