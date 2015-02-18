//
//  SetProfileRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetProfileRequest: NevoRequest {
    
    override func getRawDataEx() -> NSArray {
        
        var age :UInt8 = 50
        var height :UInt8 = 175 //cm
        var weight :UInt8 = 70  //kg
        var sex:UInt8 = 1; //man:1,female:0
        var unit:UInt8 = 1; //unit ???
        
        var values1 :[UInt8] = [0x00,0x20,
            UInt8(age&0xFF),
            UInt8(height&0xFF),
            UInt8(weight&0xFF),
            UInt8(sex&0xFF),
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,0x20,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
   
}