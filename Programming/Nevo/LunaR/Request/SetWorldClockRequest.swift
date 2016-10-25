//
//  SetWorldClockRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetWorldClockRequest: NevoRequest {
    fileprivate var _timerOffset:Int = 0 //value from -23 to 23,default 0 => RTC
    
    /*
     This header is the key by which this kind of packet is called.
     */
    class func HEADER() -> UInt8 {
        return 0x03
    }
    
    /**
     @ledpattern, define Led light pattern
     @motorOnOff, vibrator true or flase
     */
    init(offset:Int){
        super.init()
        _timerOffset = offset;
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,SetWorldClockRequest.HEADER(),UInt8(_timerOffset&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,SetWorldClockRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
