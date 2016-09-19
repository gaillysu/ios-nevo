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
        
        let values1 :[UInt8] = [0x00,GetStepsGoalRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,GetStepsGoalRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
