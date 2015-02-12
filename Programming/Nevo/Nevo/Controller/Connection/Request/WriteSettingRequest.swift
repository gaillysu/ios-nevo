//
//  WriteSettingRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class WriteSettingRequest: NevoRequest {
    
    override func getRawDataEx() -> NSArray {
   
        var walk_stride :UInt16 = 50
        var run_stride :UInt16 = 60
        var swiming_stride :UInt16 = 70
        var enable:UInt8 = 3; //bit0:1, bit1:1
        
        
        var values1 :[UInt8] = [0x00,0x21,
            UInt8(walk_stride&0xFF),
            UInt8((walk_stride>>8)&0xFF),
            
            UInt8(run_stride&0xFF),
            UInt8((run_stride>>8)&0xFF),
            
            UInt8(swiming_stride&0xFF),
            UInt8((swiming_stride>>8)&0xFF),
            
            UInt8(enable&0xFF),
            
            0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,0x21,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
   
}
