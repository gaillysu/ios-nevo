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
        var values1 :[UInt8] = [UInt8(listNumber&0xFF),UInt8(appidLength&0xFF),UInt8(ledPattern&0xFF),UInt8((ledPattern>>8)&0xFF),UInt8((ledPattern>>16)&0xFF)]
        let data:Data = appidString.data(using: .utf8)!
        let dataByte:[UInt8] = values1+NSData2Bytes(data)
        var dataValue:[[UInt8]] = []
        
        if values1.count>=18 {
            let header:UInt8 = 0x00
            for index:Int in 0..<dataByte.count/18 {
                var streetsSlice = dataByte[index*18 ..< 18]
                if dataValue.count == 0 {
                    streetsSlice.insert(header, at: 0)
                    streetsSlice.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                    dataValue.append((streetsSlice as! [UInt8]))
                }else{
                    streetsSlice.insert(header+UInt8(dataValue.count&0xFF), at: 0)
                    streetsSlice.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                    dataValue.append((streetsSlice as! [UInt8]))
                }
            }
            var streetsSlice:[UInt8] = []
            if values1.count%18 == 0{
                streetsSlice = dataValue[dataValue.count-1]
                streetsSlice.replaceSubrange(0..<1, with: [0xFF])
                dataValue.replaceSubrange(dataValue.count-2..<dataValue.count-1, with: [streetsSlice])
            }else{
                let remainderValue:Int = values1.count%18
                streetsSlice = (values1[values1.count-remainderValue ..< remainderValue]) as! [UInt8]
                streetsSlice.insert(0xFF, at: 0)
                streetsSlice.insert(SetNotificationAppIDRequest.HEADER(), at: 1)
                for index:Int in streetsSlice.count..<20 {
                    streetsSlice.append(0)
                }
                dataValue.append((streetsSlice))
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
