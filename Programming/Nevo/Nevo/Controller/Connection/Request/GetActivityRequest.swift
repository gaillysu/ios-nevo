//
//  GetActivityRequest.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class GetActivityRequest: NevoRequest {
    
    override func getRawDataEx() -> NSArray {
        
        var values1 :[UInt8] = [0x00,0x25,
            0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        var values2 :[UInt8] = [0xFF,0x25,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
}