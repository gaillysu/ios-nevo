//
//  ReceiveNewNotificationPacket.swift
//  Nevo
//
//  Created by Cloud on 2016/11/17.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class ReceiveNewNotificationPacket: LunaRPacket {

    func totalStoredApps()->Int {
        let totalApp:Int = Int(NSData2Bytes(getPackets()[0])[2])
        return totalApp
    }
    
    func getAappIDLength()->Int {
        let length:Int = Int(NSData2Bytes(getPackets()[0])[3])
        return length
    }
    
    func getApplicationID()->String {
        var data:[UInt8] = NSData2Bytes(getPackets()[0])
        data.removeSubrange(0..<4)
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
