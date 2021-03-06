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
        
        let values1 :[UInt8] = [0x00,ReadBatteryLevelNevoRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,ReadBatteryLevelNevoRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }


}
