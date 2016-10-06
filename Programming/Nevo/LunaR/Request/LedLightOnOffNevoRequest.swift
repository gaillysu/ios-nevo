//
//  LedLightOnOffNevoRequest.swift
//  Nevo
//
//  Created by supernova on 15/5/26.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class LedLightOnOffNevoRequest: NevoRequest {
    /**
    0nly use bit0..23,  every bit match one led light, bit23 is used vibrator on/off
    0 means the led light off, 1 means the led light on
    @see SetNortificationRequest.SetNortificationRequestValues
    */
    fileprivate var mLedpattern:UInt32?
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x44
    }
    /**
    @ledpattern, define Led light pattern
    @motorOnOff, vibrator true or flase
    */
    init(ledpattern:UInt32,  motorOnOff:Bool)
    {
        if (motorOnOff)
        {
            mLedpattern = ledpattern | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }
        else
        {
            mLedpattern = ledpattern & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }
    }
    
    override func getRawDataEx() -> NSArray {
      
        let values1 :[UInt8] = [0x00,LedLightOnOffNevoRequest.HEADER(),
            0xFF,
            0xFF,
            0x00,
            0x00,
            0x00,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,LedLightOnOffNevoRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }

}
