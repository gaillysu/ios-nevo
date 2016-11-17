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
        
        return 1
    }
    
    func getLEDPattern() -> UInt32 {
        
        return 0xFFFFFF
    }
    
    func getApplicationID()->String {
        
        for index:Int in 3..<100 {
            
        }
        return "121212"
    }
    
}
