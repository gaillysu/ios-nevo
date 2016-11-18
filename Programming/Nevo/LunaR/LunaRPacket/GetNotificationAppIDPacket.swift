//
//  GetNotificationAppIDPacket.swift
//  Nevo
//
//  Created by Cloud on 2016/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class GetNotificationAppIDPacket: LunaRPacket {

    func getAappIDLength()->Int {
        let appidLength:Int = Int(NSData2Bytes(getPackets()[0])[2])
        return appidLength
    }
    
    func getLEDPatternisEnable() ->Int {
        let appidLength:Int = Int(NSData2Bytes(getPackets()[0])[2])<<8
        return appidLength
    }
    
    func getLEDPattern() -> UInt32 {
        return 0xFFFFFF
    }
    
    func getApplicationID()->String {
        var data:[UInt8] = NSData2Bytes(getPackets()[0])
        data.removeSubrange(0..<7)
        for index:Int in 1..<getPackets().count {
            var dataValue = NSData2Bytes(getPackets()[index])
            dataValue.removeSubrange(0..<2)
            data = data+dataValue
        }
        let idString:String = String(data: Bytes2NSData(data), encoding: .utf8)!
        return idString
    }
    
}
