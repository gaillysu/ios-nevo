//
//  ReadBatteryLevelNevoRequest.swift
//  Nevo
//
//  Created by supernova on 15/5/26.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class ReadBatteryLevelNevoRequest: NevoRequest {
    /**
    batt_level
    0 - low battery level
    1 - half battery level
    2 - full battery level
    */
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x40
    }
    
    override func getRawDataEx() -> NSArray {
        
        var values1 :[UInt8] = [0x00,ReadBatteryLevelNevoRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,ReadBatteryLevelNevoRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }


}
