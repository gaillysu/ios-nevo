//
//  WatchNamePacket.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/13.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class WatchNamePacket: NevoPacket {
    /**
     return the watch id 1-3...
     - returns: 1-Nevo,2-Nevo Solar,3-Lunar,0xff-Nevo
     */
    func getWatchID() ->Int {
        let watch_id:Int = Int(getPackets()[0].data2Bytes()[2] )
        return watch_id
    }
    
    /**
     return the model number
     - returns: 1 - Paris,2 - New York,3 - ShangHai
     */
    func getModelNumber() ->Int {
        let modelNumber:Int = Int(getPackets()[0].data2Bytes()[5] )
        return modelNumber
    }

}
