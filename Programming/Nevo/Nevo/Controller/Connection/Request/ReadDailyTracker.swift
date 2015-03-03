//
//  ReadDailyTracker.swift
//  Nevo
//
//  Created by supernova on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class ReadDailyTracker: NevoRequest {
    let CMD:UInt8 = 0x25
    // tracker no is 0~6
    private var mTrackerNo:UInt8 = 0
    
    init(trackerno:UInt8)
    {
        mTrackerNo = trackerno
    }
    
    override func getRawDataEx() -> NSArray {
        
        var values1 :[UInt8] = [0x00,CMD,
            mTrackerNo,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,CMD,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

}
