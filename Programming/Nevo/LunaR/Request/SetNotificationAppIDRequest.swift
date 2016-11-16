//
//  SetNotificationAppIDRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetNotificationAppIDRequest: NevoRequest {
    fileprivate var listNumber:Int = 0
    fileprivate var appidLength:Int = 0
    fileprivate var ledPattern:UInt32 = 0
    fileprivate var appidString:String = ""
    
    class func HEADER() -> UInt8 {
        return 0x52
    }
    
    init(number:Int,length:Int,pattern:UInt32,appid:String,motorOnOff:Bool) {
        super.init()
        listNumber = number
        appidLength = length
        appidString = appid
        
        if (motorOnOff){
            ledPattern = pattern | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }else{
            ledPattern = pattern & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }
    }
    
    //TODO: 还没有做完
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x00,SetNotificationAppIDRequest.HEADER(),UInt8(listNumber&0xFF),UInt8(appidLength&0xFF),UInt8(ledPattern&0xFF),UInt8((ledPattern>>8)&0xFF),UInt8((ledPattern>>16)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,SetNotificationAppIDRequest.HEADER(),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
