//
//  BatteryLevelNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/5/26.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class BatteryLevelNevoPacket: NevoPacket {

/**
    return battery level
     batt_level
     0 - low battery level(<3.5)
     1 - half battery level(3.5-3.9)
     2 - full battery level(>3.9)
     0xff - not ready
*/
   func getBatteryLevel() ->Int {
    return Int(NSData2Bytes(getPackets()[0])[2] )
   }

    /*
     batt_capacity
     0-100%
     0xff - not ready
     */
    
    func getBattCapacity() ->Int {
        return Int(NSData2Bytes(getPackets()[0])[3] )
    }
    
    func isReadBatteryCommand(_ data:[Data])->Bool{
        let header:UInt8 = NSData2Bytes(data[0])[0]
        let instruction:UInt8 = NSData2Bytes(data[0])[1]
        if(header == 0x00 && instruction == 0x40 ){
            return true
        }else{
            return false
        }
    }
}
