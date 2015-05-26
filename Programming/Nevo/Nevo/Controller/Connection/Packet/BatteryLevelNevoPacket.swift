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
    0 - low battery level
    1 - half battery level
    2 - full battery level
*/
   func getBatteryLevel() ->Int
   {
    return Int(NSData2Bytes(getPackets()[0])[2] )
   }
}
