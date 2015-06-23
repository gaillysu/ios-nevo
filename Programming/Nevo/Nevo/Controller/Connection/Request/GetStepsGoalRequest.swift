//
//  GetStepsGoalRequest.swift
//  Nevo
//
//  Created by supernova on 15/3/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation

class GetStepsGoalRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x26
    }
    
    override func getRawDataEx() -> NSArray {
        
        var values1 :[UInt8] = [0x00,GetStepsGoalRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,GetStepsGoalRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
}