//
//  SetCardioRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetCardioRequest: NevoRequest {
    
    override func getRawDataEx() -> NSArray {
        
        var maxHR :UInt8 = 210
        var restHR :UInt8 = 65
        var zone_HR_H :UInt8 = 180
        var zone_HR_L :UInt8 = 60
        
        var values1 :[UInt8] = [0x00,0x23,
            UInt8(maxHR&0xFF),
            UInt8(restHR&0xFF),
            UInt8(zone_HR_H&0xFF),
            UInt8(zone_HR_L&0xFF),
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,0x23,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

   
}