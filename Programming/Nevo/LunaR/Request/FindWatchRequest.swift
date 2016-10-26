//
//  FindWatchRequest.swift
//  Nevo
//
//  Created by leiyuncun on 2016/10/6.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

enum FindWatchLEDType:Int{
    case allWhiteLED = 0,
    allColorLED = 1
}

class FindWatchRequest: NevoRequest {
    fileprivate let allLED:UInt32 = 0x3F0000
    fileprivate let whiteLED:UInt32 = 0xFFFF00
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
    init(ledtype:FindWatchLEDType,  motorOnOff:Bool){
        var ledValu:UInt32 = 0x00
        switch ledtype.rawValue {
        case 0:
            ledValu = whiteLED
        case 1:
            ledValu = allLED
        default:
            break
        }
        
        if (motorOnOff){
            mLedpattern = ledValu | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }else{
            mLedpattern = ledValu & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,FindWatchRequest.HEADER(),UInt8(mLedpattern!&0xFF),UInt8((mLedpattern!>>8)&0xFF),UInt8((mLedpattern!>>16)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,FindWatchRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
