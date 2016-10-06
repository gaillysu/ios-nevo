//
//  FindWatchRequest.swift
//  Nevo
//
//  Created by leiyuncun on 2016/10/6.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class FindWatchRequest: NevoRequest {
    /*
     This header is the key by which this kind of packet is called.
     */
    class func HEADER() -> UInt8 {
        return 0x45
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x00,FindWatchRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,FindWatchRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
