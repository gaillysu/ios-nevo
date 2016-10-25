//
//  SetSunriseAndSunsetRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetSunriseAndSunsetRequest: NevoRequest {
    fileprivate var _sunrise:Date?
    fileprivate var _sunset:Date?
    
    /*
     This header is the key by which this kind of packet is called.
     */
    class func HEADER() -> UInt8 {
        return 0x28
    }
    
    /**
     @ledpattern, define Led light pattern
     @motorOnOff, vibrator true or flase
     */
    init(sunrise:Date,  sunset:Date){
        super.init()
        _sunrise = sunrise;
        _sunset = sunset;
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,SetSunriseAndSunsetRequest.HEADER(),
                                UInt8(_sunrise!.hour&0xFF),
                                UInt8(_sunrise!.minute&0xFF),
                                UInt8(_sunset!.hour&0xFF),
                                UInt8(_sunset!.minute&0xFF),
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,SetSunriseAndSunsetRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }

}
