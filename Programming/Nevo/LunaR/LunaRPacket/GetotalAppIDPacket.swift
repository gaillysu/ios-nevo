//
//  GetotalAppIDPacket.swift
//  Nevo
//
//  Created by Cloud on 2016/11/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class GetotalAppIDPacket: LunaRPacket {

    //max 32 apps
    func getTotalAppsNumber()->Int {
        let appNumber:Int = Int(NSData2Bytes(getPackets()[0])[2])
        return appNumber
    }
}
