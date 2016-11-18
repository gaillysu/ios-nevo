//
//  DeleteNotificationAppIDRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/17.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class DeleteNotificationAppIDRequest: NevoRequest {
    fileprivate var listNumber:Int = 0 //0-31
    
    class func HEADER() -> UInt8 {
        return 0x53
    }
    
    init(number:Int) {
        super.init()
        listNumber = number
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,DeleteNotificationAppIDRequest.HEADER(),UInt8(listNumber&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,DeleteNotificationAppIDRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
