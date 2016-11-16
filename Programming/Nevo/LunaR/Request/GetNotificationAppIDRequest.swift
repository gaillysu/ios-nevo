//
//  GetNotificationAppIDRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class GetNotificationAppIDRequest: NevoRequest {
    fileprivate var listNumber:Int = 0
    
    class func HEADER() -> UInt8 {
        return 0x51
    }
    
    init(number:Int) {
        super.init()
        listNumber = number
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,GetNotificationAppIDRequest.HEADER(),UInt8(listNumber&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,GetNotificationAppIDRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
