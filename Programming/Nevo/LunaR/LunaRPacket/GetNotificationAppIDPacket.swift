//
//  GetNotificationAppIDPacket.swift
//  Nevo
//
//  Created by Cloud on 2016/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

class GetNotificationAppIDPacket: LunaRPacket {

    //APPID data length[max = 100 bytes]
    func getAappIDLength()->Int {
        let appidLength:Int = Int(NSData2Bytes(getPackets()[0])[2])
        XCGLogger.default.debug("appidLength:\(appidLength)")
        var dec2bit = String(appidLength, radix: 2)
        if dec2bit.characters.count<8 {
            for i in 0..<8-dec2bit.length() {
                dec2bit.insert("0", at: dec2bit.index(dec2bit.startIndex, offsetBy: 0))
            }
        }
        let value = dec2bit.replacingCharacters(in: dec2bit.startIndex..<dec2bit.index(dec2bit.startIndex, offsetBy: 1), with: "0")
        let bin2decValue = bin2dec(num: value)
        let length = bin2decValue
        return length
    }
    
    //5B LED pattern Disable(0)/Enable(1)
    func getLEDPatternisEnable() ->Int {
        let appidLength:Int = Int(NSData2Bytes(getPackets()[0])[2])
        let dec2bit = String(appidLength, radix: 2)
        let index = dec2bit.index(dec2bit.startIndex, offsetBy: 1)
        let value = dec2bit[index]
        let enable = "\(value)".toInt()
        return enable
    }
    
    func getLEDPattern() -> UInt32 {
        return 0xFFFFFF
    }
    
    func getApplicationID()->String {
        var data:[UInt8] = NSData2Bytes(getPackets()[0])
        data.removeSubrange(0..<8)
        let length:Int = self.getAappIDLength()
        
        for index:Int in 1..<getPackets().count {
            var dataValue = NSData2Bytes(getPackets()[index])
            dataValue.removeSubrange(0..<2)
            data = data+dataValue
        }
        data.removeSubrange(length..<data.count)
        let idString:String = String(data: Bytes2NSData(data), encoding: .utf8)!
        return idString
    }
    
}
