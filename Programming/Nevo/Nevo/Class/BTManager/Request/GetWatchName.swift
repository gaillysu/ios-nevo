//
//  GetWatchName.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/13.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class GetWatchName: NevoRequest {
    class func HEADER() -> UInt8 {
        return 0x27
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x00,GetWatchName.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,GetWatchName.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
