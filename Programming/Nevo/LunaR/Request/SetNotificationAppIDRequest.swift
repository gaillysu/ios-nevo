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
    
    override func getRawDataEx() -> NSArray {
        let data:Data = appidString.data(using: .utf8)!
        let values1:[UInt8] = [0x00,SetNotificationAppIDRequest.HEADER(),0x80,UInt8(appidLength&0xFF),UInt8(ledPattern&0xFF),UInt8((ledPattern>>8)&0xFF),UInt8((ledPattern>>16)&0xFF)]+NSData2Bytes(data)
        var dataValue:[[UInt8]] = []
        let header:UInt8 = 0x00
        let header1:UInt8 = 0xFF
        
        var dataValue2:[UInt8] = []
        for (index,value) in values1.enumerated() {
            if dataValue2.count<20 {
                dataValue2.append(value)
                if index == values1.count-1 {
                    for _ in dataValue2.count..<20 {
                        dataValue2.append(header)
                    }
                    dataValue.append(dataValue2)
                    
                    dataValue2 = []
                    if dataValue.count<2 {
                        dataValue2.insert(header1, at: 0)
                        dataValue2.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                        for _ in 0..<18 {
                            dataValue2.append(header)
                        }
                        dataValue.append(dataValue2)
                    }
                }
            }else{
                dataValue.append(dataValue2)
                dataValue2 = [];
                if (values1.count - index)>20 {
                    dataValue2.insert(header+UInt8(dataValue.count&0xFF), at: 0)
                    dataValue2.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                }else{
                    dataValue2.insert(header1, at: 0)
                    dataValue2.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                }
                dataValue2.append(value)
            }
        }
        
        let array:NSMutableArray = NSMutableArray()
        for value in dataValue{
            let data:Data = Data(bytes: UnsafePointer<UInt8>(value), count: value.count)
            array.add(data)
        }
        return array
    }
}
