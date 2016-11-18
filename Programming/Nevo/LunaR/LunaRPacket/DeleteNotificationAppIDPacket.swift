//
//  DeleteNotificationAppIDPacket.swift
//  Nevo
//
//  Created by Cloud on 2016/11/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class DeleteNotificationAppIDPacket: LunaRPacket {

    /*
     Status
     0 - OK
     1 - Flash Busy
     2 - Low Battery
     3 - List not Exist
     */
    func getDeleteStatus() ->Int  {
        let status:Int = Int(NSData2Bytes(getPackets()[0])[2])
        return status
    }
}
