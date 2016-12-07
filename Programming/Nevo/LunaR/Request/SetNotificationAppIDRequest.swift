//
//  SetNotificationAppIDRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class SetNotificationAppIDRequest: NevoRequest {
    fileprivate var listNumber:Int = 0
    fileprivate var appidLength:Int = 0
    fileprivate var ledPattern:UInt32 = 0
    fileprivate var appidString:String = ""
    fileprivate var motorValue:UInt8 = 0
    
    fileprivate var rValue:Int = 0
    fileprivate var gValue:Int = 0
    fileprivate var bValue:Int = 0
    
    class func HEADER() -> UInt8 {
        return 0x52
    }
    
    init(number:Int,hexColor:String,appid:String,notiFictionOnOff:Bool,motorOnOff:Bool) throws {
        super.init()
        listNumber = number
        appidLength = appid.characters.count
        appidString = appid
        
        if (motorOnOff){
            motorValue = UInt8(0x88&0xFF)
        }else{
            motorValue = UInt8(0x00&0xFF)
        }
        
        if notiFictionOnOff {
            var value = dec2bin(number: appidLength)
            if value.characters.count<8 {
                for _ in value.characters.count..<8 {
                    value.insert("0", at: value.startIndex)
                }
            }
            value.replaceSubrange(value.startIndex..<value.index(value.startIndex, offsetBy: 1), with: "1")
            
            appidLength = bin2dec(num: value)
        }
        
        let hexString: String = hexColor.substring(from: hexColor.characters.index(hexColor.startIndex, offsetBy: 1))
        var hexValue:  UInt32 = 0
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            throw UIColorInputError.unableToScanHexValue
        }
        rValue      = Int((hexValue & 0xFF0000) >> 16)
        gValue      = Int((hexValue & 0x00FF00) >>  8)
        bValue      = Int( hexValue & 0x0000FF       )
    }
    
    override func getRawDataEx() -> NSArray {
        let data:Data = appidString.data(using: .utf8)!
        let values1:[UInt8] = [0x00,SetNotificationAppIDRequest.HEADER(),0x80,UInt8(appidLength&0xFF),0x00,motorValue,UInt8(rValue&0xFF),UInt8(gValue&0xFF),UInt8(bValue&0xFF)]+NSData2Bytes(data)
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
